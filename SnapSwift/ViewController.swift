//
//  ViewController.swift
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

class ViewController: UIViewController, SnapSwiftParameterChangedDelegate
{
    var snapSwift: SnapSwift!
    var snapSwiftParameters: [SnapSwiftParameter]!
    let photograph = UIImage(named: "assets/DSCF0261.jpg")
    let imageView = UIImageView(frame: CGRectZero)
    let ciContext = CIContext(options: nil)
    
    let presetColors = [PresetColors.Custom.rawValue,
                        PresetColors.Red.rawValue, PresetColors.Green.rawValue, PresetColors.Blue.rawValue,
                        PresetColors.Cyan.rawValue, PresetColors.Magenta.rawValue, PresetColors.Yellow.rawValue]
    
    override func viewDidLoad()
    {
        let cmykLabel: Float -> String = {(NSString(format: "%d", Int($0 * 100)) as String) + "%"}
        let rgbLabel: Float -> String = {(NSString(format: "%02X", Int($0 * 255)) as String)}
        let presetLabel: Float -> String = { self.presetColors[Int($0 * Float(self.presetColors.count - 1))] }
        
        snapSwiftParameters =
            [SnapSwiftParameter(label: "Red", normalisedValue: 0, labelFunction: rgbLabel),
                SnapSwiftParameter(label: "Green", normalisedValue: 0, labelFunction: rgbLabel),
                SnapSwiftParameter(label: "Blue", normalisedValue: 1, labelFunction: rgbLabel),
                SnapSwiftParameter(label: "Cyan", normalisedValue: 0, labelFunction: cmykLabel),
                SnapSwiftParameter(label: "Magenta", normalisedValue: 0, labelFunction: cmykLabel),
                SnapSwiftParameter(label: "Yellow", normalisedValue: 0, labelFunction: cmykLabel),
                SnapSwiftParameter(label: "Black", normalisedValue: 0, labelFunction: cmykLabel),
                SnapSwiftParameter(label: "Monochrome Intensity", normalisedValue: 0.75),
                SnapSwiftParameter(label: "Color Preset", normalisedValue: 0, labelFunction: presetLabel, stringValues: presetColors)]
        
        super.viewDidLoad()
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        view.addSubview(imageView)
        
        view.backgroundColor = UIColor.lightGrayColor()
        
        snapSwift = SnapSwift(viewController: self, view: imageView)
        snapSwift.parameters = snapSwiftParameters
        snapSwift.parameterChangedDelegate = self
        
        snapSwiftParameterDidChange(parameterIndex: 0, parameters: snapSwiftParameters)
    }
    
    func snapSwiftParameterDidChange(parameterIndex parameterIndex:Int, parameters: [SnapSwiftParameter])
    {
        snapSwiftParameters = parameters
        
        if parameterIndex == -1 || (parameterIndex >= 0 && parameterIndex <= 2) // adjusting rgb...
        {
            let red = CGFloat(snapSwiftParameters[0].normalisedValue)
            let green = CGFloat(snapSwiftParameters[1].normalisedValue)
            let blue = CGFloat(snapSwiftParameters[2].normalisedValue)
            
            view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
            
            let black = 1 - max(red, green, blue)
            let cyan = black != 1 ? (1 - red - black) / (1 - black) : 0
            let magenta = black != 1 ? (1 - green - black) / (1 - black) : 0
            let yellow = black != 1 ? (1 - blue - black) / (1 - black) : 0

            snapSwiftParameters[3].normalisedValue = Float(cyan)
            snapSwiftParameters[4].normalisedValue = Float(magenta)
            snapSwiftParameters[5].normalisedValue = Float(yellow)
            snapSwiftParameters[6].normalisedValue = Float(black)
            
            if parameterIndex != -1
            {
                snapSwiftParameters[8].selectedIndex = 0
                setPresetFromColors()
            }
        }
        else if parameterIndex >= 3 && parameterIndex <= 6 // adjusting cmyk...  
        {
            let cyan = CGFloat(snapSwiftParameters[3].normalisedValue)
            let magenta = CGFloat(snapSwiftParameters[4].normalisedValue)
            let yellow = CGFloat(snapSwiftParameters[5].normalisedValue)
            let black = CGFloat(snapSwiftParameters[6].normalisedValue)
            
            let red = black != 1 ? (1 - cyan) * (1 - black) : 0
            let green = black != 1 ? (1 - magenta) * (1 - black) : 0
            let blue = black != 1 ? (1 - yellow) * (1 - black) : 0
            
            view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
            
            snapSwiftParameters[0].normalisedValue = Float(red)
            snapSwiftParameters[1].normalisedValue = Float(green)
            snapSwiftParameters[2].normalisedValue = Float(blue)
            
            snapSwiftParameters[8].selectedIndex = 0
            setPresetFromColors()
        }
        else if parameterIndex == 8 // changing preset color
        {
            let colorsIndex = Int(snapSwiftParameters[8].normalisedValue * Float(presetColors.count - 1))
            
            setRgbFromPresetColor(colorsIndex)
        }
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {self.applyImageFilter()})
        
        snapSwift.parameters = snapSwiftParameters
    }
   
    func setPresetFromColors()
    {
        let rgb = (r: snapSwiftParameters[0].normalisedValue, g: snapSwiftParameters[1].normalisedValue, b: snapSwiftParameters[2].normalisedValue)
        let presetColorIndex: Int
        
        switch rgb
        {
        case (1, 0, 0):
            presetColorIndex = 1
        case (0, 1, 0):
            presetColorIndex = 2
        case (0, 0, 1):
            presetColorIndex = 3
        case (0, 1, 1):
            presetColorIndex = 4
        case (1, 0, 1):
            presetColorIndex = 5
        case (1, 1, 0):
            presetColorIndex = 6
        default:
            presetColorIndex = 0
        }
        
        snapSwiftParameters[8].selectedIndex = presetColorIndex
    }
    
    func setRgbFromPresetColor(index: Int)
    {
        if let presetColor = PresetColors(rawValue: presetColors[index])
        {
            let newRGB: (r: Float, g: Float, b: Float)
            
            switch presetColor
            {
            case .Custom:
                newRGB = (snapSwiftParameters[0].normalisedValue, snapSwiftParameters[1].normalisedValue, snapSwiftParameters[2].normalisedValue)
            case .Red:
                newRGB = (1, 0, 0)
            case .Green:
                newRGB = (0, 1, 0)
            case .Blue:
                newRGB = (0, 0, 1)
            case .Cyan:
                newRGB = (0, 1, 1)
            case .Magenta:
                newRGB = (1, 0, 1)
            case .Yellow:
                newRGB = (1, 1, 0)
            }
            
            snapSwiftParameters[0].normalisedValue = newRGB.r
            snapSwiftParameters[1].normalisedValue = newRGB.g
            snapSwiftParameters[2].normalisedValue = newRGB.b
            
            // this is a bit hacky: use -1 to prevent snapSwiftParameterDidChange() from resetting the 
            // preset colors value...
            snapSwiftParameterDidChange(parameterIndex: -1, parameters: snapSwiftParameters)
        }
    }
    
    func applyImageFilter()
    {
        let monochromeFilter = CIFilter(name: "CIColorMonochrome")
        let monochromeColor = CIColor(red: CGFloat(snapSwiftParameters[0].normalisedValue),
            green: CGFloat(snapSwiftParameters[1].normalisedValue),
            blue: CGFloat(snapSwiftParameters[2].normalisedValue),
            alpha: 1)
        
        let monochromeInensity = CGFloat(snapSwiftParameters[7].normalisedValue)
        
        monochromeFilter!.setValue(CIImage(image: photograph!), forKey: kCIInputImageKey)
        monochromeFilter!.setValue(monochromeColor, forKey: "inputColor")
        monochromeFilter!.setValue(monochromeInensity, forKey: "inputIntensity")
        
        let filteredImageData = monochromeFilter!.valueForKey(kCIOutputImageKey) as! CIImage!
        
        let filteredImageRef = ciContext.createCGImage(filteredImageData, fromRect: filteredImageData.extent)
        
        let filteredImage = UIImage(CGImage: filteredImageRef)
        
        dispatch_async(dispatch_get_main_queue(), {self.imageView.image = filteredImage})
    }

    override func viewDidLayoutSubviews()
    {
        imageView.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y, width: view.frame.width, height: view.frame.height).insetBy(dx: 50, dy: 50)
    }
    
}

enum PresetColors: String
{
    case Custom = "Custom"
    case Red = "Red"
    case Green = "Green"
    case Blue = "Blue"
    case Cyan = "Cyan"
    case Magenta = "Magenta"
    case Yellow = "Yellow"
}
