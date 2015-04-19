//
//  SnapSwift.swift
//  SnapSwift
//
//  Created by Simon Gladman on 17/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

let snapSwiftRowHeight = 50
let snapSwiftColumnWidth = 200

class SnapSwift: NSObject
{
    let snapSwiftContentViewController = SnapSwiftContentViewController()
    let viewController: UIViewController
    let view: UIView
    var tap: SnapSwiftPanGestureRecognizer!
    var previousTouchLocation = CGPointZero
    
    weak var parameterChangedDelegate: SnapSwiftParameterChangedDelegate?
    {
        didSet
        {
            snapSwiftContentViewController.parameterChangedDelegate = parameterChangedDelegate
        }
    }
    
    init(viewController: UIViewController, view: UIView)
    {
        self.viewController = viewController
        self.view = view
        self.view.userInteractionEnabled = true

        super.init();
        
        tap = SnapSwiftPanGestureRecognizer(target: self, action: "tapHandler:")
        view.addGestureRecognizer(tap)
        
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
            previousTouchLocation = recognizer.locationInView(view)
            
            open()
        }
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            let touchLocation = recognizer.locationInView(view)
            
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
        
        viewController.presentViewController(snapSwiftContentViewController, animated: false, completion: nil)
    }
    
    private func close()
    {
        viewController.dismissViewControllerAnimated(false, completion: nil)
        
    }
    
}



