//
//  SnapSwiftContentViewController.swift
//  SnapSwift
//
//  Created by Simon Gladman on 19/04/2015.
//  Copyright (c) 2015 Simon Gladman. All rights reserved.
//

class SnapSwiftContentViewController: UIViewController
{
    var selectedWidgetIndex = 0
    let background = UIView(frame: CGRectZero)
    let centreLine = CALayer()
    
    weak var parameterChangedDelegate: SnapSwiftParameterChangedDelegate?
    
    override func viewDidLoad()
    {
        view.userInteractionEnabled = false
        
        centreLine.cornerRadius = 4
        centreLine.borderWidth = 1
        centreLine.backgroundColor  = UIColor(red: 1, green: 1, blue: 0, alpha: 0.25).CGColor
        centreLine.borderColor  = UIColor(red: 1, green: 1, blue: 0, alpha: 0.5).CGColor
        view.layer.addSublayer(centreLine)
        
        background.backgroundColor = UIColor.clearColor()
        view.addSubview(background)
    }
    
    override func viewDidLayoutSubviews()
    {
        let bgHeight = CGFloat(parameters.count * snapSwiftRowHeight)
        
        background.frame = CGRect(
            x: view.frame.width / 2 - CGFloat(snapSwiftColumnWidth / 2),
            y: view.frame.height / 2  - bgHeight / 2,
            width: CGFloat(snapSwiftColumnWidth),
            height: bgHeight)
        
        centreLine.frame = CGRect(
            x: view.frame.width / 2 - CGFloat(snapSwiftColumnWidth / 2),
            y: view.frame.height / 2  - CGFloat(snapSwiftRowHeight / 2),
            width: CGFloat(snapSwiftColumnWidth),
            height: CGFloat(snapSwiftRowHeight)).rectByInsetting(dx: -5, dy: -1)
    }
    
    func handleMovement(#deltaX: CGFloat, deltaY: CGFloat)
    {
        if abs(deltaY) > 0 // vertical movement...
        {
            (background.subviews[selectedWidgetIndex] as? SnapSwiftParameterWidget)?.selected = false
            
            let backgroundNewY = min(max(background.frame.origin.y - deltaY, view.frame.height / 2 - background.frame.height + CGFloat(snapSwiftRowHeight / 2)), view.frame.height / 2 - CGFloat(snapSwiftRowHeight / 2))
            
            background.frame.origin.y = backgroundNewY
            
            selectedWidgetIndex = Int((view.frame.height / 2 - backgroundNewY)) / snapSwiftRowHeight
            
            (background.subviews[selectedWidgetIndex] as? SnapSwiftParameterWidget)?.selected = true
        }
        else if abs(deltaX) > 0 // horizontal movement...
        {
            let snappedBackgroundOriginY = view.frame.height / 2  - CGFloat(Float(snapSwiftRowHeight) * 0.5) - CGFloat(selectedWidgetIndex * snapSwiftRowHeight)
            
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.animateWithDuration(0.3, animations: { self.background.frame.origin.y = snappedBackgroundOriginY })
            
            let newValue = min(max(0, parameters[selectedWidgetIndex].normalisedValue - Float(deltaX / 250)), 1)
            
            parameters[selectedWidgetIndex].normalisedValue = newValue
            
            parameterChangedDelegate?.snapSwiftParameterDidChange(parameterIndex: selectedWidgetIndex, parameters: parameters)
        }
    }
    
    var parameters: [SnapSwiftParameter] = [SnapSwiftParameter]()
    {
        didSet
        {
            let oldParamNames = ":".join(oldValue.map{ $0.label })
            let paramNames = ":".join(parameters.map{ $0.label })
            
            if oldParamNames != paramNames
            {
                rebuildUI()
                
                handleMovement(deltaX: 0, deltaY: 0.1)
            }
            else
            {
                for (var i: Int, var widget) in enumerate(background.subviews)
                {
                    (widget as? SnapSwiftParameterWidget)?.parameter = parameters[i]
                }
            }
        }
    }
    
    private func rebuildUI()
    {
        for child in background.subviews
        {
            (child as? UIView)?.removeFromSuperview()
        }
        
        for (var i: Int, var parameter) in enumerate(parameters)
        {
            let widget = SnapSwiftParameterWidget()
            widget.parameter = parameter
            
            widget.frame = CGRect(x: 0, y: i * snapSwiftRowHeight, width: snapSwiftColumnWidth, height: snapSwiftRowHeight)
            
            background.addSubview(widget)
        }
        
        viewDidLayoutSubviews()
    }
}

