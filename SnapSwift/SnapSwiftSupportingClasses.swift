//
//  SnapSwiftSupportingClasses.swift
//  SnapSwift
//
//  Created by Simon Gladman on 18/04/2015.
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

/// A simple parameter for the SnapSwift component
struct SnapSwiftParameter
{
    var label: String
    var normalisedValue: Float
    var labelFunction: Float -> String
    var stringValues: [String]?
    
    init(label: String, normalisedValue: Float, labelFunction: Float -> String = { NSString(format: "%.2f", $0) as String }, stringValues: [String]? = nil)
    {
        self.label = label
        self.normalisedValue = normalisedValue
        self.labelFunction = labelFunction
        self.stringValues = stringValues
    }
    
    var selectedIndex: Int?
    {
        get
        {
            if let stringValues = stringValues
            {
                return Int(normalisedValue * Float(stringValues.count - 1))
            }
            else
            {
                return nil
            }
        }
        set
        {
            if let stringValues = stringValues, selectedIndex = newValue
            {
                println("\(selectedIndex) ..... \((1 / Float(stringValues.count + 1)) * Float(selectedIndex))")
                
                normalisedValue = (1 / Float(stringValues.count - 1)) * Float(selectedIndex)
            }
            else
            {
                // ignore
            }
        }
    }
}

/// Protocol for responding to parameter changes 
protocol SnapSwiftParameterChangedDelegate: NSObjectProtocol
{
    func snapSwiftParameterDidChange(#parameterIndex:Int, parameters: [SnapSwiftParameter])
}


/// A UIView to display a set of string values
class SnapSwiftWing: UIView
{
    let itemRendererWidth = 100
    let side: SnapSwiftWingSide
    
    required init(side: SnapSwiftWingSide)
    {
        self.side = side
        
        super.init(frame: CGRectZero)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    let itemsContainer = CALayer()
    
    var stringValues: [String] = [String]()
    {
        didSet
        {
            layer.addSublayer(itemsContainer)
            
            layer.masksToBounds = true
            
            layer.sublayers.map({($0 as? SnapSwiftWingItemRenderer)?.removeFromSuperlayer()})
            
            for (var index: Int, string: String) in enumerate(stringValues)
            {
                let itemRenderer = SnapSwiftWingItemRenderer(label: string)
                itemRenderer.frame = CGRect(x: index * itemRendererWidth, y: 0, width: itemRendererWidth, height: snapSwiftRowHeight).rectByInsetting(dx: 2.5, dy: 5)
                
                itemsContainer.addSublayer(itemRenderer)
            }
            
            itemsContainer.frame = CGRect(x: 0, y: 0, width: stringValues.count * itemRendererWidth, height: snapSwiftRowHeight)
            selectedIndex = 0
        }
    }
    
    var selectedIndex: Int = 0
    {
        didSet
        {
            switch side
            {
            case .right:
                itemsContainer.frame.origin.x = CGFloat(0 - (selectedIndex + 1) * 100)
            case .left:
                itemsContainer.frame.origin.x = layer.bounds.width - CGFloat(selectedIndex * 100)
            }
            
        }
    }
    
}

/// Item renderer for SnapSwiftWing to display a string
class SnapSwiftWingItemRenderer: CALayer
{
    let textLayer = CATextLayer()
    
    required init(label: String)
    {
        super.init()
        
        backgroundColor = UIColor(white: 0.667, alpha: 0.8).CGColor
        borderColor = UIColor.darkGrayColor().CGColor
        cornerRadius = 4
        borderWidth = 1
        
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.fontSize = 18
        textLayer.string = label
        
        addSublayer(textLayer)
    }

    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers()
    {
        super.layoutSublayers()
        
        textLayer.frame = CGRect(x: 0, y: bounds.height / 2 - 10, width: bounds.width, height: 25)
    }
    
    var label:String?
    {
        didSet
        {
            textLayer.string = label
        }
    }
}

enum SnapSwiftWingSide
{
    case left
    case right
}

/// An extended UIPanGestureRecognizer that fires UIGestureRecognizerState.Began
/// with the first touch down, i.e. without requiring any movement.
class SnapSwiftPanGestureRecognizer: UIPanGestureRecognizer
{
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent!)
    {
        super.touchesBegan(touches, withEvent: event)
        
        state = UIGestureRecognizerState.Began
    }
}