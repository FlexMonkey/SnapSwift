# SnapSwift
SnapSeed Style Popup Menu for iOS

A combined popup menu / numeric slider component for iOS in the style of Google's Snapseed app.

![http://flexmonkey.co.uk/swift/IMG_0699.PNG](http://flexmonkey.co.uk/swift/SnapSwift.PNG)

After playing with Google's Snapseed app, I was inspired to recreate their user interface as a reusable component in Swift. Snapseed does away with fixed sliders or dials cluttering the screen, rather the user touches the screen and with a vertical pan can select between parameters and with a horizontal pan can change the value of that parameter.

My component, SnapSwift, works in a similar way. However, I humbly suggest that my implementation improves on Google's: with SnapSwift, a single touch gesture can change parameter selection and values. With Google's, the initial pan direction sets a mode so that after changing parameter selection, the user needs to lift their finger and begin a new gesture to change the value. 

I've created a simple demonstration app that applies a CIMonochromeFilter to a photograph. Simply touching anywhere on the image view brings up the SnapSwift menu.

Changing the red, green or blue values updates the cyan, magenta, yellow and black values and vice versa. Changes to any of the values updates the filter and the image on the screen.

The demo shows how simple adding SnapSwift to any project is and all the demo code is all in my view controller. SnapSwift menu items are defined as an array of SnapSeedParameter instances: 

```
        snapSwiftParameters =
                [SnapSwiftParameter(label: "Red", normalisedValue: 0, labelFunction: rgbLabel),
                ...
                SnapSwiftParameter(label: "Cyan", normalisedValue: 0, labelFunction: cmykLabel),
                ...

                SnapSwiftParameter(label: "Monochrome Intensity", normalisedValue: 0.5)]
```

label and normalisedValue are self explanatory. labelFunction is an optional parameter of the type Float -> String that defines how the normalisedValue is rendered. I want RGB values displayed as hex and CMYK displayed as a percentage, so I defined them as:

```
        let cmykLabel: Float -> String = {(NSString(format: "%d", Int($0 * 100)) as String) + "%"}
        let rgbLabel: Float -> String = {(NSString(format: "%02X", Int($0 * 255)) as String)}
```

The final parameter in my array, Monochrome Intensity, uses the default formatter which is two decimal places.

Once the parameters have been defined, I create an instance of SnapSwift defining both a view controller and which UIView will open the menu, assign that instance the parameters and set its delegate:

```
        snapSwift = SnapSwift(viewController: self, view: imageView)
        snapSwift.parameters = snapSwiftParameters

        snapSwift.parameterChangedDelegate = self
```

The delegate, SnapSwiftParameterChangedDelegate, only contains one method, snapSwiftParameterDidChange(), which is fired when the user has changed the value of any parameter via a horizontal pan. It has two arguments, the index in the array of which parameter has changed and an updated copy of the parameters array. The first handful of lines of my snapSwiftParameterDidChange() look like this:

```
    func snapSwiftParameterDidChange(#parameterIndex:Int, parameters: [SnapSwiftParameter])
    {
        snapSwiftParameters = parameters
        
        if parameterIndex >= 0 && parameterIndex <= 2 // adjusting rgb...
        {
            let red = CGFloat(snapSwiftParameters[0].normalisedValue)
            let green = CGFloat(snapSwiftParameters[1].normalisedValue)

            let blue = CGFloat(snapSwiftParameters[2].normalisedValue)
            ...
```

That's all there is to it! Whenever the user touches my image view (which is the UIImage in the centre of my screen), SnapSwift does the rest, popping up the menu, handling the touch gestures and reporting back via the delegate methods. 

Let's look inside SnapSwift to see how it's put together. 

Creating the SnapSwift instance attaches a gesture recogniser to the supplied UIView. This is an extended UIPanGestureRecognizer named SnapSwiftGestureRecognizer. I've overridden the touchesBegan function so that it reports back a Began state on the first touch rather than waiting for a pan to begin. 

When the user touches the screen, I invoke presentViewController on the supplied view controller to present an instance of SnapSwiftContentViewController over the current context:

```
    private func open()
    {
        snapSwiftContentViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        snapSwiftContentViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        viewController.presentViewController(snapSwiftContentViewController, animated: false, completion: nil)

    }
```

...and when the touch moves, I invoke handleMovement() on the same instance:

```
        ...
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            let touchLocation = recognizer.locationInView(view)
            
            let deltaX = previousTouchLocation.x - touchLocation.x
            let deltaY = previousTouchLocation.y - touchLocation.y
            
            snapSwiftContentViewController.handleMovement(deltaX: deltaX, deltaY: deltaY)
            
            previousTouchLocation = touchLocation

        }
        ...
```

SnapSwift also passes SnapSwiftContentViewController the parameters array.  In the didSet observer, the latter checks to see if the parameter structure has changed (for example if a parameter has been added or removed) and if it has, rebuilds the menu list as a set of SnapSwiftParameterWidgets, if not, it can simply reset the parameters on each of the existing widgets:

```
    var parameters: [SnapSwiftParameter] = [SnapSwiftParameter]()
    {
        didSet
        {
            let oldParamNames = ":".join(oldValue.map{ $0.label })
            let paramNames = ":".join(parameters.map{ $0.label })
            
            if oldParamNames != paramNames
            {
                rebuildUI()
                
                handleMovement(deltaX: 0, deltaY: 0.1)
            }
            else
            {
                for (var i: Int, var widget) in enumerate(background.subviews)
                {
                    (widget as? SnapSwiftParameterWidget)?.parameter = parameters[i]
                }
            }
        }

    }
```

Inside SnapSwiftContentViewController's handleMovement() method, the code decides whether to respond to vertical or horizontal movement. With vertical movement, the background container is moved by the same distance as the touch movement and then figures out the selected parameter menu item based on the position:

```
    func handleMovement(#deltaX: CGFloat, deltaY: CGFloat)
    {
        if abs(deltaY) > 0 // vertical movement...
        {
            (background.subviews[selectedWidgetIndex] as? SnapSwiftParameterWidget)?.selected = false
            
            let backgroundNewY = min(max(background.frame.origin.y - deltaY, view.frame.height / 2 - background.frame.height + CGFloat(snapSwiftRowHeight / 2)), view.frame.height / 2 - CGFloat(snapSwiftRowHeight / 2))
            
            background.frame.origin.y = backgroundNewY
            
            selectedWidgetIndex = Int((view.frame.height / 2 - backgroundNewY)) / snapSwiftRowHeight
            
            (background.subviews[selectedWidgetIndex] as? SnapSwiftParameterWidget)?.selected = true

        }
        ...
```

With horizontal movement, the normalisedValue is changed by the movement divided by 250 and the background is moved vertically to centre the selected parameter widget on the screen. This centering is useful to reduce the chance of accidentally changing parameter selection during a horizontal movement:

```
        ...
        else if abs(deltaX) > 0 // horizontal movement...
        {
            let snappedBackgroundOriginY = view.frame.height / 2  - CGFloat(Float(snapSwiftRowHeight) * 0.5) - CGFloat(selectedWidgetIndex * snapSwiftRowHeight)
            
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.animateWithDuration(0.3, animations: { self.background.frame.origin.y = snappedBackgroundOriginY })
            
            let newValue = min(max(0, parameters[selectedWidgetIndex].normalisedValue - Float(deltaX / 250)), 1)
            
            parameters[selectedWidgetIndex].normalisedValue = newValue
            
            parameterChangedDelegate?.snapSwiftParameterDidChange(parameterIndex: selectedWidgetIndex, parameters: parameters)

        }
```

As I mentioned above, the parameter menu displayed to the user is built from SnapSwiftParameterWidget instances. These little UIViews contain two labels, for the title and value, a UIProgressView to graphically represent the value and and a CALayer for the background. 

When the parameter changes, a didSet observer updates the labels (the value label uses the parameter's labelFunction) and progress bar:

```
    var parameter: SnapSwiftParameter?
    {
        didSet
        {
            if let parameter = parameter
            {
                titleLabel.text = parameter.label
                valueLabel.text = parameter.labelFunction(parameter.normalisedValue)
                progressView.progress = parameter.normalisedValue

            }
            ...
```

To implement SnapSwift in your own project, you simply need to copy over three files: SnapSwift.swift, SnapSwiftViewController.swift and SnapSwiftSupportingClasses.swift. The only other requirement is to add an import to your bridging header to allow the extension of UIGestureRecognizerSubclass.

For more information, visit my blog: http://flexmonkey.blogspot.co.uk/search/label/SnapSwift
