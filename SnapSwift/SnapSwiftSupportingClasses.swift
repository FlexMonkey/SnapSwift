//
//  SnapSwiftSupportingClasses.swift
//  SnapSwift
//
//  Created by Simon Gladman on 18/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

/// A simple parameter for the SnapSwift component
struct SnapSwiftParameter
{
    var label: String
    var normalisedValue: Float
}

/// A bordered box with label and float value display
class SnapSwiftParameterWidget: UIView
{
    let backgroundLayer = CALayer()
    let label = UILabel()
    
    override func didMoveToSuperview()
    {
       backgroundLayer.borderColor = UIColor.blueColor().CGColor
        backgroundLayer.borderWidth = 1
        backgroundLayer.cornerRadius = 4

        layer.addSublayer(backgroundLayer)
        
        label.textAlignment = NSTextAlignment.Center
        
        addSubview(label)
        
        selected = false
    }
    
    var selected: Bool = false
    {
        didSet
        {
            label.textColor = selected ? UIColor.whiteColor() : UIColor.blueColor()
            backgroundLayer.backgroundColor = selected ? UIColor.blueColor().CGColor : UIColor.whiteColor().CGColor
        }
    }
    
    var parameter: SnapSwiftParameter?
    {
        didSet
        {
            label.text = parameter?.label
        }
    }
    
    override func layoutSubviews()
    {
        label.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height).rectByInsetting(dx: 0, dy: 0.5)
    }
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