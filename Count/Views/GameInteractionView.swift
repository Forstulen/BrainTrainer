//
//  Button.swift
//  Count
//
//  Created by Romain Tholimet on 07/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import UIKit
import Spring

enum GameViewType : Equatable {
    case number, op
}

@objc enum ArithmeticExpression : Int {
    case num
    case add
    case sub
    case mul
    case div
}

@IBDesignable class GameInteractionView : SpringView, Animatable, UIGestureRecognizerDelegate {
    
    //MARK: Properties
    var value : String  = "" {
        didSet {
            textLabel.text = value
        }
    }
    @IBInspectable var width : Int     = 75
    @IBInspectable var height : Int    = 75
    
    var isConfigured : Bool = false
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBInspectable var cornerRadius : CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderColor : UIColor? {
        didSet {
            self.layer.borderColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable var borderWidth : CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var arithmeticExpression : ArithmeticExpression = .num {
        didSet {
            switch arithmeticExpression {
                case .num:
                    type = .number
                default:
                    type = .op
            }
        }
    }
    
    var type : GameViewType = .number
    
    //MARK: Initializer
    
    
    //MARK: Public Methods
    func configureView(value : String, index : Int, maximumViewNumber : Int, radius : Float, center : CGPoint) {
        self.value = value
        
        reconfigureView(index: index, maximumViewNumber: maximumViewNumber, radius: radius, center: center)
    }
    
    func reconfigureView(index : Int, maximumViewNumber : Int, radius : Float, center : CGPoint) {
        
        let (point, frame) = self.createFrame(index, maximumViewNumber, radius, center)
        
        self.frame = frame;
        if !isConfigured {
            isUserInteractionEnabled = true
            self.center = CGPoint(x : point.x, y : point.y);
            animateTo(scale: 1.0)
            isConfigured = true
        } else {
            animateTo(x: Int(point.x), y: Int(point.y))
        }
    }
    
    //MARK: Private Methods
    private func createFrame(_ index : Int, _ maximumViewNumber : Int, _ radius : Float, _ center : CGPoint) -> (CGPoint, CGRect) {
        
        let angle           = 360.0 / Float(maximumViewNumber)
        let partialAngle    = -angle * Float(index)
        let x               = radius * sin(partialAngle * Float.pi / 180.0) + Float(center.x)
        let y               = radius * cos(partialAngle * Float.pi / 180.0) + Float(center.y)
        
//        self.width = Int(center.x * 0.4)
//        self.height = Int(center.y * 0.2)
        
        return (CGPoint(x: Int(x), y: Int(y)) ,CGRect(x: Int(self.frame.origin.x), y: Int(self.frame.origin.y), width: self.width, height: self.height))
    }
 
    //MARK: Protocol Methods
    func animateTo(x: Int, y: Int) {
        SpringAnimation.springEaseOut(duration: 0.75, animations: {
            self.center = CGPoint(x : x, y : y);
        })
    }
    
    func animateTo(scale : CGFloat = 1) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        SpringAnimation.springEaseOut(duration: 0.5, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
    
    func fadeOut(initColor: UIColor) {
        let savedColor = self.backgroundColor
        self.backgroundColor = initColor
        
        UIView.animate(withDuration: 0.5) {
            self.backgroundColor = savedColor
        }
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        animation.isRemovedOnCompletion = true
        
        self.layer.add(animation, forKey: "position")
    }
    
    func fadeIn(finalColor: UIColor) {
        let savedColor = self.backgroundColor
        
        UIView.animate(withDuration: 1.0, delay : 0.25, options: [.autoreverse],  animations: {
            self.backgroundColor = finalColor
        }) { (isFinished) in
            self.backgroundColor = savedColor
        }
    }
}
