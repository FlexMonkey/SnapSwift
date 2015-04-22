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
}

/// Protocol for responding to parameter changes 
protocol SnapSwiftParameterChangedDelegate: NSObjectProtocol
{
    func snapSwiftParameterDidChange(#parameterIndex:Int, parameters: [SnapSwiftParameter])
}

class StringValueCell: UICollectionViewCell
{
    var titleString:String = ""
    {
        didSet
        {
            label.text = titleString
        }
    }
    
    var label : UILabel = UILabel(frame: CGRectZero)
    
    override func didMoveToSuperview()
    {
        label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        label.numberOfLines = 0
        label.textColor = UIColor.whiteColor()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = NSTextAlignment.Center
        
        layer.backgroundColor = UIColor(white: 0.667, alpha: 0.8).CGColor
        layer.borderColor = UIColor.darkGrayColor().CGColor
        layer.cornerRadius = 4
        layer.borderWidth = 1
        contentView.addSubview(label)
        
        label.text = titleString
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