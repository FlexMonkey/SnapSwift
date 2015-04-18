//
//  SnapSwift.swift
//  SnapSwift
//
//  Created by Simon Gladman on 17/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class SnapSwift: NSObject
{
    let snapSwiftContentViewController = SnapSwiftContentViewController()
    let viewController: UIViewController
    var tap: SnapSwiftPanGestureRecognizer!
    var previousTouchLocation = CGPointZero
    
    init(viewController: UIViewController)
    {
        self.viewController = viewController

        super.init()
        
        tap = SnapSwiftPanGestureRecognizer(target: self, action: "tapHandler:")
        viewController.view.addGestureRecognizer(tap)
        
        snapSwiftContentViewController.view.backgroundColor = UIColor.clearColor()
    }

    deinit
    {
        viewController.view.removeGestureRecognizer(tap)
    }
    
    var parameters: [SnapSwiftParameter] = [SnapSwiftParameter]()
    {
        didSet
        {
           snapSwiftContentViewController.parameters = parameters
        }
    }
    
    func tapHandler(recognizer: SnapSwiftPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            previousTouchLocation = recognizer.locationInView(viewController.view)
            
            open()
        }
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            let touchLocation = recognizer.locationInView(viewController.view)
            
            let deltaX = previousTouchLocation.x - touchLocation.x
            let deltaY = previousTouchLocation.y - touchLocation.y
            
            snapSwiftContentViewController.handleMovement(deltaX: deltaX, deltaY: deltaY)
            
            previousTouchLocation = touchLocation
        }
        else
        {
            close()
            
            previousTouchLocation = CGPointZero
        }
    }
    
    private func open()
    {
        snapSwiftContentViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        snapSwiftContentViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        viewController.presentViewController(snapSwiftContentViewController, animated: true, completion: nil)
    }
    
    private func close()
    {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}


class SnapSwiftContentViewController: UIViewController
{
    let background = UIView(frame: CGRectZero)

    override func viewDidLoad()
    {
        background.backgroundColor = UIColor.clearColor()
        view.addSubview(background)
    }

    override func viewDidLayoutSubviews()
    {
        let bgHeight = CGFloat(parameters.count * 30)
        
        background.frame = CGRect(
            x: view.frame.width / 2 - 100,
            y: view.frame.height / 2  - bgHeight / 2,
            width: 200,
            height: bgHeight)
    }
    
    var selectedWidgetIndex = 0
    
    func handleMovement(#deltaX: CGFloat, deltaY: CGFloat)
    {
        (background.subviews[selectedWidgetIndex] as? SnapSwiftParameterWidget)?.selected = false
        
        let backgroundNewY = min(max(background.frame.origin.y - deltaY, view.frame.height / 2 - background.frame.height + 15), view.frame.height / 2 - 15)
        
        background.frame.origin.y = backgroundNewY
        
        selectedWidgetIndex = Int((view.frame.height / 2 - backgroundNewY)  / 30)

        (background.subviews[selectedWidgetIndex] as? SnapSwiftParameterWidget)?.selected = true
    }
    
    var parameters: [SnapSwiftParameter] = [SnapSwiftParameter]()
    {
        didSet
        {
            rebuildUI()
            handleMovement(deltaX: 0, deltaY: 0)
        }
    }
    
    private func rebuildUI()
    {
        for child in background.subviews
        {
            (child as? UIView)?.removeFromSuperview()
        }
        
        for (var i: Int, var parameter) in enumerate(parameters)
        {
            let widget = SnapSwiftParameterWidget()
            widget.parameter = parameter
            
            widget.frame = CGRect(x: 0, y: i * 30, width: 200, height: 30)
            
            background.addSubview(widget)
        }
        
        viewDidLayoutSubviews()
    }
}

