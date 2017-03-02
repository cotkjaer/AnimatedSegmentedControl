//
//  AnimatedSegmentedControl.swift
//  AnimatedSegmentedControl
//
//  Created by Christian Otkjær on 01/03/17.
//  Copyright © 2017 Silverback IT. All rights reserved.
//

import UIKit

@IBDesignable open class AnimatedSegmentedControl: UIControl
{
    private var labels: [UILabel] = []
    
    private let selectionIndicatorView = UIView()
    
    open var items: [String] = ["Item 1", "Item 2", "Item 3"] {
        didSet {
            setupLabels()
        }
    }
    
    open var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    @IBInspectable open var selectedTextColor: UIColor = UIColor.black {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable open var unselectedTextColor: UIColor = UIColor.white
        {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable open var selectionIndicatorColor: UIColor = UIColor.white
        {
        didSet {
            updateColors()
        }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable open var borderWidth: CGFloat = 2
        {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable open var font: UIFont! = UIFont.systemFont(ofSize: UIFont.buttonFontSize) {
        didSet {
            updateFont()
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override open func awakeFromNib()
    {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup()
    {
        layer.cornerRadius = frame.height / 2
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
        
        backgroundColor = UIColor.clear
        
        setupLabels()
        
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
        
        insertSubview(selectionIndicatorView, at: 0)
    }
    
    func setupLabels()
    {
        labels.forEach { $0.removeFromSuperview() }
        
        labels.removeAll(keepingCapacity: true)
        
        for (index, item) in items.enumerated()
        {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
            label.text = item
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = UIFont(name: "Avenir-Black", size: 15)
            label.textColor = index == selectedIndex ? selectedTextColor : unselectedTextColor
            label.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(labels, mainView: self, padding: 0)
    }
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.height / 2

        var selectFrame = self.bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        selectionIndicatorView.frame = selectFrame
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        selectionIndicatorView.layer.cornerRadius = selectionIndicatorView.frame.height / 2
        
        displayNewSelectedIndex()
    }
    
    // MARK: - Tracking
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool
    {
        let location = touch.location(in: self)
        
        guard let index = labels.index(where: { $0.frame.contains(location) }) else { return false }

        selectedIndex = index
        sendActions(for: .valueChanged)
        
        return false
    }
    
    var frameforSelectedIndex: CGRect?
        {
        return labels.enumerated().first(where: {$0.offset == selectedIndex })?.element.frame
    }
    
    func displayNewSelectedIndex()
    {
        labels.enumerated().forEach{ $0.element.textColor = $0.offset == selectedIndex ? selectedTextColor : unselectedTextColor }
        
        
        guard let frame = frameforSelectedIndex else { return }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: [], animations: {
            
            self.selectionIndicatorView.frame = frame
            
        }, completion: nil)
    }
    
    func addIndividualItemConstraints(_ items: [UIView], mainView: UIView, padding: CGFloat)
    {
//        let constraints = mainView.constraints
        
        for (index, button) in items.enumerated()
        {
            let topConstraint = NSLayoutConstraint(
                item: button,
                attribute: .top,
                relatedBy: .equal,
                toItem: mainView,
                attribute: .top,
                multiplier: 1,
                constant: 0)
            
            let bottomConstraint = NSLayoutConstraint(
                item: button,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: mainView,
                attribute: .bottom,
                multiplier: 1,
                constant: 0)
            
            let rightConstraint: NSLayoutConstraint
            
            if index == items.count - 1
            {
                rightConstraint = NSLayoutConstraint(
                    item: button,
                    attribute: .right,
                    relatedBy: .equal,
                    toItem: mainView,
                    attribute: .right,
                    multiplier: 1,
                    constant: -padding)
            }
            else
            {
                let nextButton = items[index+1]
                
                rightConstraint = NSLayoutConstraint(
                    item: button,
                    attribute: .right,
                    relatedBy: .equal,
                    toItem: nextButton,
                    attribute: .left,
                    multiplier: 1,
                    constant: -padding)
            }
            
            let leftConstraint: NSLayoutConstraint
            
            if index == 0
            {
                leftConstraint = NSLayoutConstraint(
                    item: button,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: mainView,
                    attribute: .left,
                    multiplier: 1,
                    constant: padding)
            }
            else
            {
                let prevButton = items[index-1]
                leftConstraint = NSLayoutConstraint(
                    item: button,
                    attribute: .left,
                    relatedBy: .equal,
                    toItem: prevButton,
                    attribute: .right,
                    multiplier: 1,
                    constant: padding)
                
                let firstItem = items[0]
                
                let widthConstraint = NSLayoutConstraint(
                    item: button, attribute: .width,
                    relatedBy: .equal,
                    toItem: firstItem,
                    attribute: .width,
                    multiplier: 1,
                    constant: 0)
                
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    func updateLabelsTextColor()
    {
        labels.enumerated().forEach{ $0.element.textColor = $0.offset == selectedIndex ? selectedTextColor : unselectedTextColor }
    }
    
    func updateColors()
    {
        updateLabelsTextColor()
        
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
    }
    
    func updateFont()
    {
        labels.forEach { $0.font = font }
    }
}

