//
//  ViewController.swift
//  SnapSwift
//
//  Created by Simon Gladman on 17/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: SnapSwiftViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = UIColor.lightGrayColor()
    }



    override func resignFirstResponder() -> Bool
    {
        return true
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent)
    {
        // super.touchesMoved(touches, withEvent: event)
        
        println("touches moved from root view controller \(view.userInteractionEnabled)")
    }
    

}

