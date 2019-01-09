//
//  Calculation.swift
//  Count
//
//  Created by Romain Tholimet on 09/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import Foundation
import ObjectMapper

enum LevelDifficulty : String {
    case easy
    case medium
    case hard
}

class Calculation : Mappable {    
    //MARK: Properties
    public var numbers  : [Int]?
    public var number   : Int?
    public var level    : LevelDifficulty?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.number     <- map["number"]
        self.numbers    <- map["numbers"]
        self.level      <- map["level"]
    }
    
    init(numbers : [Int], number : Int) {
        self.numbers    = numbers
        self.number     = number
    }
}
