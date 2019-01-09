//
//  Status.swift
//  Count
//
//  Created by Romain Tholimet on 10/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import Foundation
import ObjectMapper

class Status : Mappable {
    //MARK: Properties
    public var indexes  : [Int]?
    public var pb       : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.indexes     <- map["indexes"]
        self.pb          <- map["pb"]
    }
    
    init(indexes : [Int], pb : String) {
        self.indexes    = indexes
        self.pb         = pb
    }
}
