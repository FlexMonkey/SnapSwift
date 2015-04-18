//
//  ViewController.swift
//  SnapSwift
//
//  Created by Simon Gladman on 17/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    let label = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 200))
    
    var snapSwift: SnapSwift!
    
    var snapSwiftParameters: [SnapSwiftParameter] =
                    [SnapSwiftParameter(label: "Red", normalisedValue: 0.5),
                        SnapSwiftParameter(label: "Green", normalisedValue: 0.9),
                        SnapSwiftParameter(label: "Blue", normalisedValue: 0.25),
                        SnapSwiftParameter(label: "Cyan", normalisedValue: 0.5),
                        SnapSwiftParameter(label: "Magenta", normalisedValue: 0.9),
                        SnapSwiftParameter(label: "Yellow", normalisedValue: 0.25),
                        SnapSwiftParameter(label: "Black", normalisedValue: 0.25)]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        label.text = "Hello from SnapSwift!!!"
        view.addSubview(label)
        
        view.backgroundColor = UIColor.lightGrayColor()
        
        snapSwift = SnapSwift(viewController: self)
        snapSwift.parameters = snapSwiftParameters
    }
    
}

