//
//  SnapSwiftParameterWidget.swift
//  SnapSwift
//
//  Created by Simon Gladman on 22/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//


/// A bordered box with label and float value display
class SnapSwiftParameterWidget: UIView
{
    let unselectedBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    
    let backgroundLayer = CALayer()
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
    
    let leftStringValuesWing = SnapSwiftWing(side: .left)
    let rightStringValuesWing = SnapSwiftWing(side: .right)
    
    var rightStringValues = [String]()
    var leftStringValues = [String]()
    
    let leftAlignedlayout = UICollectionViewFlowLayout()
    
    init()
    {
        super.init(frame: CGRectZero)
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
                
                leftStringValuesWing.stringValues = stringValues
                rightStringValuesWing.stringValues = stringValues
                
                layoutSubviews()
            }
            
            let selectedIndexInStringValues = Int(parameter.normalisedValue * Float(stringValues.count - 1))

            rightStringValuesWing.selectedIndex = selectedIndexInStringValues
            leftStringValuesWing.selectedIndex = selectedIndexInStringValues
        }
        else
        {
            removeStringValueWings()
        }
    }
    
    func removeStringValueWings()
    {
        leftStringValuesWing.removeFromSuperview()
        rightStringValuesWing.removeFromSuperview()
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



