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
    
    private func tapHandler(recognizer: SnapSwiftPanGestureRecognizer)
    {
        if recognizer.state == UIGestureRecognizerState.Began
        {
            open(); println("open! \(recognizer.locationInView(viewController.view))")
        }
        else if recognizer.state == UIGestureRecognizerState.Changed
        {
            println("moved \(recognizer.locationInView(viewController.view))")
        }
        else
        {
            close()
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
    let label = UILabel(frame: CGRect(x: 50, y: 50, width: 200, height: 200))
    let background = UIView(frame: CGRectZero)
    
    override func viewDidLoad()
    {
        background.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.25)
        view.addSubview(background)
        
        label.text = "Hello inside SnapSwift!!!"
        view.addSubview(label)
    }

    override func viewDidLayoutSubviews()
    {
        background.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
    
    var parameters: [SnapSwiftParameter] = [SnapSwiftParameter]()
}


