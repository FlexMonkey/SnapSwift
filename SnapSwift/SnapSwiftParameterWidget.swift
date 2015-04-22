//
//  SnapSwiftParameterWidget.swift
//  SnapSwift
//
//  Created by Simon Gladman on 22/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//


/// A bordered box with label and float value display
class SnapSwiftParameterWidget: UIView, UICollectionViewDataSource, UICollectionViewDelegate
{
    let unselectedBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    
    let backgroundLayer = CALayer()
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
    
    let leftStringValuesWing: UICollectionView
    let rightStringValuesWing: UICollectionView
    
    var rightStringValues = [String]()
    var leftStringValues = [String]()
    
    let leftAlignedlayout = UICollectionViewFlowLayout()
    
    init()
    {
        leftAlignedlayout.scrollDirection = .Horizontal
        leftAlignedlayout.itemSize = CGSize(width: 100, height: snapSwiftRowHeight)
        
        rightStringValuesWing = UICollectionView(frame: CGRectZero, collectionViewLayout: leftAlignedlayout)
        rightStringValuesWing.backgroundColor = UIColor.clearColor()
        
        rightStringValuesWing.registerClass(StringValueCell.self, forCellWithReuseIdentifier: "Cell")
        
        // ---
        
        let rightAlignedlayout = UICollectionViewRightAlignedLayout()
        rightAlignedlayout.scrollDirection = .Horizontal
        rightAlignedlayout.itemSize = CGSize(width: 100, height: snapSwiftRowHeight)
        
        leftStringValuesWing = UICollectionView(frame: CGRectZero, collectionViewLayout: rightAlignedlayout)
        leftStringValuesWing.backgroundColor = UIColor.clearColor()
        
        leftStringValuesWing.registerClass(StringValueCell.self, forCellWithReuseIdentifier: "Cell")
        
        // ---
        
        super.init(frame: CGRectZero)
        
        rightStringValuesWing.dataSource = self
        rightStringValuesWing.delegate = self
        
        leftStringValuesWing.dataSource = self
        leftStringValuesWing.delegate = self
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
        return collectionView == rightStringValuesWing ? rightStringValues.count : leftStringValues.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! StringValueCell
        
        cell.titleString = collectionView == rightStringValuesWing ? rightStringValues[indexPath.item] : leftStringValues[indexPath.item]
        
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
                
                layoutSubviews()
            }
            
            let selectedIndexInStringValues = Int(parameter.normalisedValue * Float(stringValues.count - 1))
            
            rightStringValues = selectedIndexInStringValues < stringValues.count - 1 ? Array(stringValues[selectedIndexInStringValues + 1 ... stringValues.count - 1]) : [String]()
            
            let rightCount = rightStringValuesWing.numberOfItemsInSection(0)
            let rightIndexPath = NSIndexPath(forItem: 0, inSection: 0)
            
            if rightCount - rightStringValues.count == -1 
            {
                rightStringValuesWing.insertItemsAtIndexPaths([ rightIndexPath ])
            }
            else if rightCount - rightStringValues.count == 1 && rightCount != 0
            {
                rightStringValuesWing.deleteItemsAtIndexPaths([ rightIndexPath ])
            }
            else
            {
                rightStringValuesWing.reloadData()
            }
            
            // ---
            
            leftStringValues = selectedIndexInStringValues > 0 ? Array(stringValues[0 ... selectedIndexInStringValues - 1]).reverse() : [String]()
            
            let leftCount = leftStringValuesWing.numberOfItemsInSection(0)
            let leftIndexPath = NSIndexPath(forItem: 0, inSection: 0)

            if leftCount - leftStringValues.count == -1 
            {
                leftStringValuesWing.insertItemsAtIndexPaths([ leftIndexPath ])
            }
            else if leftCount - leftStringValues.count == 1 && leftCount != 0
            {
                leftStringValuesWing.deleteItemsAtIndexPaths([ leftIndexPath ])
            }
            else
            {
                leftStringValuesWing.reloadData()
            }

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

