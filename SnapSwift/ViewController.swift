//
//  ViewController.swift
//  SnapSwift
//
//  Created by Simon Gladman on 17/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SnapSwiftParameterChangedDelegate
{
    let label = UILabel(frame: CGRect(x: 10, y: 10, width: 200, height: 200))
    
    var snapSwift: SnapSwift!
    var snapSwiftParameters: [SnapSwiftParameter]!
    
    override func viewDidLoad()
    {
        let cmykLabel: Float -> String = {(NSString(format: "%d", Int($0 * 100)) as String) + "%"}
        let rgbLabel: Float -> String = {(NSString(format: "%20X", Int($0 * 255)) as String)}
        
        snapSwiftParameters =
            [SnapSwiftParameter(label: "Red", normalisedValue: 0.5, labelFunction: rgbLabel),
            SnapSwiftParameter(label: "Green", normalisedValue: 0.9, labelFunction: rgbLabel),
            SnapSwiftParameter(label: "Blue", normalisedValue: 0.25, labelFunction: rgbLabel),
            SnapSwiftParameter(label: "Cyan", normalisedValue: 0.5, labelFunction: cmykLabel),
            SnapSwiftParameter(label: "Magenta", normalisedValue: 0.9, labelFunction: cmykLabel),
            SnapSwiftParameter(label: "Yellow", normalisedValue: 0.25, labelFunction: cmykLabel),
            SnapSwiftParameter(label: "Black", normalisedValue: 0.25, labelFunction: cmykLabel)]
        
        super.viewDidLoad()
        
        label.text = "Hello from SnapSwift!!!"
        view.addSubview(label)
        
        view.backgroundColor = UIColor.lightGrayColor()
        
        snapSwift = SnapSwift(viewController: self)
        snapSwift.parameters = snapSwiftParameters
        snapSwift.parameterChangedDelegate = self
    }
    
    func snapSwiftParameterDidChange(#parameterIndex:Int, parameters: [SnapSwiftParameter])
    {
        snapSwiftParameters = parameters
        
        if parameterIndex >= 0 && parameterIndex <= 2 // adjusting rgb...
        {
            let red = CGFloat(snapSwiftParameters[0].normalisedValue)
            let green = CGFloat(snapSwiftParameters[1].normalisedValue)
            let blue = CGFloat(snapSwiftParameters[2].normalisedValue)
            
            view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
            
            let black = 1 - max(red, green, blue)
            let cyan = (1 - red - black) / (1 - black)
            let magenta = (1 - green - black) / (1 - black)
            let yellow = (1 - blue - black) / (1 - black)

            snapSwiftParameters[3].normalisedValue = Float(cyan)
            snapSwiftParameters[4].normalisedValue = Float(magenta)
            snapSwiftParameters[5].normalisedValue = Float(yellow)
            snapSwiftParameters[6].normalisedValue = Float(black)
        }
        else if parameterIndex >= 3 && parameterIndex <= 6 // adjusting cmyk...  
        {
            let cyan = CGFloat(snapSwiftParameters[3].normalisedValue)
            let magenta = CGFloat(snapSwiftParameters[4].normalisedValue)
            let yellow = CGFloat(snapSwiftParameters[5].normalisedValue)
            let black = CGFloat(snapSwiftParameters[6].normalisedValue)
            
            let red = (1 - cyan) * (1 - black)
            let green = (1 - magenta) * (1 - black)
            let blue = (1 - yellow) * (1 - black)
            
            view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
            
            snapSwiftParameters[0].normalisedValue = Float(red)
            snapSwiftParameters[1].normalisedValue = Float(green)
            snapSwiftParameters[2].normalisedValue = Float(blue)
        }
        
        
        snapSwift.parameters = snapSwiftParameters
    }
    
}

