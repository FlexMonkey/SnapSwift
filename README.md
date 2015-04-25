# SnapSwift
Snapseed Style Popup Menu for iOS

A combined popup menu / slider component for iOS in the style of Google's Snapseed app.

![/SnapSwift/assets/SnapSwiftScreenRecording.gif](/SnapSwift/assets/SnapSwiftScreenRecording.gif)

SnapSwift allows users to select and edit continuous or discrete parameters with a single touch anywhere on the screen. A vertical movement selects across a list of parameters and a horizontal movement changes the currently selected parameter's value.

# Usage

SnapSwift is instatiated with two arguments, a ```UIViewController``` and a target ```UIView```. The latter is the view that responds to the touch event so that different components in the same screen can have their own SnapSwift instances:

```
snapSwift = SnapSwift(viewController: self, view: imageView)
```

SnapSwift requires a list of paramters, which are ```SnapSwiftParameter``` instances, to present to the user. Parameters have:

* ```label``` - the label displayed to the user
* ```normalisedValue``` - the ```Float``` value between zero and one
* ```labelFunction``` - an optional function of type ```Float -> String``` which defines how the ```normalisedValue``` is rendered
* ```stringValues``` - an optional array of strings for selecting across discrete values
 
In the example above, the parameter array looks a little like this:

```
let cmykLabel: Float -> String = {(NSString(format: "%d", Int($0 * 100)) as String) + "%"}
let rgbLabel: Float -> String = {(NSString(format: "%02X", Int($0 * 255)) as String)}
let presetLabel: Float -> String = { self.presetColors[Int($0 * Float(self.presetColors.count - 1))] }
let presetColors = ["Red", "Green", "Blue"...
        
snapSwiftParameters =
        [SnapSwiftParameter(label: "Red", normalisedValue: 0, labelFunction: rgbLabel),
        ...
        SnapSwiftParameter(label: "Magenta", normalisedValue: 0, labelFunction: cmykLabel),
        ...
        SnapSwiftParameter(label: "Color Preset", normalisedValue: 0, labelFunction: presetLabel, stringValues: presetColors)]
```

The parameters are set on the SnapSwift instance by setting the ```parameters``` property:

```
snapSwift.parameters = snapSwiftParameters
```

Finally, the delegate protocol, ```SnapSwiftParameterChangedDelegate```, allows SnapSwift's host to respond to user activity by the ```snapSwiftParameterDidChange()``` function:

```
snapSwift.parameterChangedDelegate = self
```

```snapSwiftParameterDidChange()``` is passed the index of the changed parameter and an updated copy of the parameters array. In the example above, my implementation of the function begins like this:

```
func snapSwiftParameterDidChange(#parameterIndex:Int, parameters: [SnapSwiftParameter])
{
    snapSwiftParameters = parameters
    
    if parameterIndex == -1 || (parameterIndex >= 0 && parameterIndex <= 2) // adjusting rgb...
    {
        let red = CGFloat(snapSwiftParameters[0].normalisedValue)
        let green = CGFloat(snapSwiftParameters[1].normalisedValue)
        let blue = CGFloat(snapSwiftParameters[2].normalisedValue)
        
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
...
```

# Demo App

The demo app uses a SnapSwift menu to enable the user to apply a ```CIColorMonochrome``` filter to an image. It demonstrates how parameters can be updated through code by setting either their ```normalisedValue``` or ```selectedIndex``` properties - the latter being ignored if a parameter's ```stringValues``` is ```nil```.

# Installation

To implement SnapSwift in your own project, you need the following four files:

* ```SnapSwift.swift```
* ```SnapSwiftSupportingClasses.swift```
*  ```SnapSwiftContentViewController.swift```
*  ```SnapSwiftParameterWidget.swift```

Furthermore, you need a bridging header with the following import:

```
#import <UIKit/UIGestureRecognizerSubclass.h>
```

