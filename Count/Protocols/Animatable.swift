//
//  Animatable
//  Count
//
//  Created by Romain Tholimet on 07/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import Foundation
import UIKit


protocol Animatable {
    func animateTo(x : Int, y : Int);
    func fadeOut(initColor : UIColor);
    func shake();
    func fadeIn(finalColor : UIColor);
}
