//
//  Seller.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 28/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class Seller {
    var email:String
    var menu:[Combo]
    var coord:CLLocation
    var imageUrl:String
    //var image:UIImage
 
    init(){
        email = ""
        menu = [Combo]()
        imageUrl = ""
        let lat = CLLocationDegrees(exactly: 0.0000)
        let long = CLLocationDegrees(exactly: 0.0000)
        coord = CLLocation(latitude: lat!, longitude: long!)
        //image = UIImage()
    }
    
    init(dict:NSDictionary){
        email = dict.value(forKey: "email") as! String
        let menuList = dict.value(forKey: "menu") as! [NSDictionary]
        menu = [Combo]()
        for comboDict in menuList {
            let newCombo = Combo(dict: comboDict)
            menu.append(newCombo)
        }
        
        let coordBackend = dict.value(forKey: "coord") as! NSDictionary
        let latit = CLLocationDegrees(exactly: coordBackend.value(forKey: "latit") as! Float)
        let long = CLLocationDegrees(exactly: coordBackend.value(forKey: "long") as! Float)
        coord = CLLocation(latitude: latit!, longitude: long!)
        
        imageUrl = dict.value(forKey: "imageUrl") as! String
        
        //let imageURL = NSURL(string: imageUrl)
        //let imagedData = NSData(contentsOf: imageURL! as URL)
        //if imagedData != nil {
        //    image = UIImage(data: imagedData as! Data)!
        //} else {
        //    image = UIImage()
        //}

        
    }
}
