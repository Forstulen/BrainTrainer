//
//  MenuView.swift
//  Count
//
//  Created by Romain Tholimet on 09/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import UIKit
import Spring

@IBDesignable class MenuButtonView: SpringButton, Animatable {
    
    //MARK: Properties
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
    
    //MARK: Protocols
    func animateTo(x: Int, y: Int) {
   
    }
    
    func animateTo(scale : CGFloat = 1) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        SpringAnimation.springEaseOut(duration: 0.5, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
    
    func fadeOut(initColor: UIColor) {
        
    }
    
    func shake() {
        
    }
    
    func fadeIn(finalColor: UIColor) {
        
    }
    

}
