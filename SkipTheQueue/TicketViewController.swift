//
//  TicketViewController.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 29/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import UIKit

class TicketViewController: UIViewController {
    
    var lastTicket:Ticket?
    
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var ticketNumber: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cerrar", style: .plain, target: self, action: #selector(hide))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setNewTicket(ticket:Ticket){
        self.lastTicket = ticket
        self.sellerName.text = lastTicket!.seller!.email
        self.ticketNumber.text = "#"+String(describing: lastTicket!.idNumber!)
    }
    
    func hide(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getLocationButtonAction(_ sender: AnyObject) {
        let lat = String(describing: lastTicket!.seller!.coord.coordinate.latitude)
        let lon = String(describing: lastTicket!.seller!.coord.coordinate.longitude)
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(NSURL(string:"http://maps.google.com/maps?q=loc:"+lat+","+lon)! as URL, options: [:],completionHandler: nil)
            //UIApplication.shared.open(NSURL(string:"comgooglemaps://?center="+lat+","+lon+"&zoom=14&views=traffic")! as URL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(NSURL(string:"http://maps.google.com/maps?q=loc:"+lat+","+lon)! as URL)
        }
    }

}
