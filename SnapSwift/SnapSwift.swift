//
//  SnapSwift.swift
//  SnapSwift
//
//  Created by Simon Gladman on 17/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class SnapSwift
{
    init()
    {
        println("hello from SnapSwift!")
    }
    
    func open(viewController: UIViewController)
    {
        let snapSwiftViewController = SnapSwiftContentViewController()
        
        snapSwiftViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        snapSwiftViewController.preferredContentSize = CGSize(width: viewController.view.frame.width, height: viewController.view.frame.height)
        
        let popoverController = UIPopoverController(contentViewController: snapSwiftViewController)
        let popoverRect = viewController.view.frame.rectByInsetting(dx: 0, dy: 0)
        
        popoverController.presentPopoverFromRect(popoverRect, inView: viewController.view, permittedArrowDirections: UIPopoverArrowDirection.allZeros, animated: true)
        
        viewController.resignFirstResponder()
        viewController.view.userInteractionEnabled = false
        snapSwiftViewController.view.exclusiveTouch = true
        
        snapSwiftViewController
        
        viewController.reloadInputViews()
    }
    
}

class SnapSwiftViewController: UIViewController
{
    let snapSwift = SnapSwift()

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesBegan(touches, withEvent: event)
        
        view.userInteractionEnabled = false
        
        snapSwift.open(self)
    }
}

class SnapSwiftContentViewController: UIViewController
{
    override func viewDidLoad()
    {
        view.backgroundColor = UIColor.darkGrayColor()
        view.exclusiveTouch = true
    }
    
    override func becomeFirstResponder() -> Bool
    {
        return true
    }
    
    override func isFirstResponder() -> Bool
    {
        return true
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        super.touchesMoved(touches, withEvent: event)
        
        println("touches moved from SnapSwiftViewController!")
    }
}

