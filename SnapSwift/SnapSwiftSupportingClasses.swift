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

/// A bordered box with label and float value display
class SnapSwiftParameterWidget: UIView, UICollectionViewDataSource, UICollectionViewDelegate
{
    let unselectedBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    
    let backgroundLayer = CALayer()
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
    
    let leftStringValuesWing = UILabel()
    let rightStringValuesWing: UICollectionView
    
    init()
    {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSize(width: 100, height: snapSwiftRowHeight)
        
        rightStringValuesWing = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        rightStringValuesWing.backgroundColor = UIColor.clearColor()
        
        rightStringValuesWing.registerClass(StringValueCell.self, forCellWithReuseIdentifier: "Cell")
        
        super.init(frame: CGRectZero)
        
        rightStringValuesWing.dataSource = self
        rightStringValuesWing.delegate = self
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow()
    {
        backgroundLayer.borderColor = UIColor.blueColor().CGColor
        backgroundLayer.borderWidth = 1
        backgroundLayer.cornerRadius = 4
        
        layer.addSublayer(backgroundLayer)
        
        titleLabel.textAlignment = NSTextAlignment.Left
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        
        valueLabel.textAlignment = NSTextAlignment.Right
        valueLabel.adjustsFontSizeToFitWidth = true
        addSubview(valueLabel)
        
        addSubview(progressView)
        
        selected = false
        
        updateWings()
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return rightStringValues.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! StringValueCell
        
        cell.titleString = rightStringValues[indexPath.item];
        
        return cell
    }
    
    var selected: Bool = false
    {
        didSet
        {
            titleLabel.textColor = selected ? UIColor.whiteColor() : UIColor.blueColor()
            valueLabel.textColor = selected ? UIColor.whiteColor() : UIColor.blueColor()
            progressView.tintColor = selected ? UIColor.whiteColor() : UIColor.blueColor()
            
            backgroundLayer.backgroundColor = selected ? UIColor.blueColor().CGColor : unselectedBackgroundColor.CGColor
        }
    }
    
    var rightStringValues = [String]()
    
    var parameter: SnapSwiftParameter?
    {
        didSet
        {
            if let parameter = parameter
            {
                titleLabel.text = parameter.label
                valueLabel.text = parameter.labelFunction(parameter.normalisedValue)
                progressView.progress = parameter.normalisedValue
                
                updateWings()
            }
            else
            {
                titleLabel.text = "-"
                valueLabel.text = "-"
                progressView.progress = 0
                
                removeStringValueWings()
            }
        }
    }
    
    func updateWings()
    {
        if let parameter = parameter, stringValues = parameter.stringValues
        {
            if !leftStringValuesWing.isDescendantOfView(self)
            {
                addSubview(leftStringValuesWing)
                addSubview(rightStringValuesWing)
                
                leftStringValuesWing.textColor  = UIColor.whiteColor()
                leftStringValuesWing.textAlignment = NSTextAlignment.Right
                
                layoutSubviews()
            }
            
            let selectedIndexInStringValues = Int(parameter.normalisedValue * Float(stringValues.count - 1))
            
            leftStringValuesWing.text = selectedIndexInStringValues > 0 ?
                " | ".join(stringValues[0 ... selectedIndexInStringValues]) : ""
            
            // rightStringValuesWing.text = selectedIndexInStringValues < stringValues.count - 1 ? " | ".join(stringValues[selectedIndexInStringValues + 1 ... stringValues.count - 1]) : ""
            
            rightStringValues = selectedIndexInStringValues < stringValues.count - 1 ? Array(stringValues[selectedIndexInStringValues + 1 ... stringValues.count - 1]) : [String]()
            
            let rightCount = rightStringValuesWing.numberOfItemsInSection(0)
            
            if rightCount - rightStringValues.count == -1 // && rightCount != 0
            {   
                rightStringValuesWing.insertItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            }
            else if rightCount - rightStringValues.count == 1 && rightCount != 0
            {
                rightStringValuesWing.deleteItemsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)])
            }
            else
            {
                rightStringValuesWing.reloadData()
            }
        }
        else
        {
            removeStringValueWings()
        }
    }
    
    func removeStringValueWings()
    {
        // leftStringValuesWing.removeFromSuperview()
        // rightStringValuesWing.removeFromSuperview()
    }
    
    override func layoutSubviews()
    {
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width / 2 + 10, height: frame.height).rectByInsetting(dx: 4, dy: 0)
        valueLabel.frame = CGRect(x: frame.width / 2, y: 0, width: frame.width / 2, height: frame.height).rectByInsetting(dx: 4, dy: 0)
        
        progressView.frame = CGRect(x: 0, y: frame.height - 4, width: frame.width, height: 0).rectByInsetting(dx: 5, dy: 0)
        
        backgroundLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height).rectByInsetting(dx: 0, dy: 0.5)
        
        if leftStringValuesWing.isDescendantOfView(self)
        {
            leftStringValuesWing.frame = CGRect(x: -300, y: 0, width: 300 - 10, height: CGFloat(snapSwiftRowHeight))
            rightStringValuesWing.frame = CGRect(x: frame.width + 10, y: 0, width: 300, height: CGFloat(snapSwiftRowHeight))
        }
    }
    

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
        
        layer.backgroundColor = UIColor.lightGrayColor().CGColor
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