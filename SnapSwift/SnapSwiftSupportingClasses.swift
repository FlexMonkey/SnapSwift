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
    var labelFunction: Float -> String
    
    init(label: String, normalisedValue: Float, labelFunction: Float -> String = { NSString(format: "%.2f", $0) as String })
    {
        self.label = label
        self.normalisedValue = normalisedValue
        self.labelFunction = labelFunction
    }
}

/// Protocol for responding to parameter changes 
protocol SnapSwiftParameterChangedDelegate: NSObjectProtocol
{
    func snapSwiftParameterDidChange(#parameterIndex:Int, parameters: [SnapSwiftParameter])
}

/// A bordered box with label and float value display
class SnapSwiftParameterWidget: UIView
{
    let unselectedBackgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    
    let backgroundLayer = CALayer()
    let titleLabel = UILabel()
    let valueLabel = UILabel()
    
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
    
    override func didMoveToSuperview()
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
            }
            else
            {
                titleLabel.text = "-"
                valueLabel.text = "-"
                progressView.progress = 0
            }
        }
    }
    
    override func layoutSubviews()
    {
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width / 2 + 10, height: frame.height).rectByInsetting(dx: 4, dy: 0)
        valueLabel.frame = CGRect(x: frame.width / 2, y: 0, width: frame.width / 2, height: frame.height).rectByInsetting(dx: 4, dy: 0)
        
        progressView.frame = CGRect(x: 0, y: frame.height - 4, width: frame.width, height: 0).rectByInsetting(dx: 5, dy: 0)
        
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