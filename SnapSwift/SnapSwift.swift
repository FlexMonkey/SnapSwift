//
//  SnapSwift.swift
//  SnapSwift
//
//  Created by Simon Gladman on 17/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

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



