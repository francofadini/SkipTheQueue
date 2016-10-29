//
//  ticket.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 29/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import Foundation

class Ticket {
    static var lastTicket:Ticket?
    
    let idNumber:Int?
    let seller:Seller?
    let status:String?
    
    init(){
        idNumber = 0
        seller = Seller()
        status = ""
    }
    
    init(idNumber:Int,seller:Seller,status:String){
        self.idNumber = idNumber
        self.seller = seller
        self.status = status
    }
}
