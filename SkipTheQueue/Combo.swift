//
//  Combo.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 28/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import Foundation

class Combo {
    var name:String
    var price:Float
    
    init(){
        name = ""
        price = 0
    }
    
    init(dict:NSDictionary){
        name = dict.value(forKey: "name") as! String
        price = dict.value(forKey: "price") as! Float
    }
}
