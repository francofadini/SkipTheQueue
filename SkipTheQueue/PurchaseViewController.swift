//
//  PurchaseViewController.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 28/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import UIKit
import MercadoPagoSDK

class PurchaseViewController: UIViewController {

    var seller:Seller?
    var purchaseCombos = [Combo]()
    var total:Float = 0.0
    var ticketView:TicketViewController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Agregar otro", style: .plain, target: self, action: #selector(hide))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pagar", style: .plain, target: self, action: #selector(self.startCheckout))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        totalLabel.text = total.asLocaleCurrency
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addCombo(_ combo:Combo){
        purchaseCombos.append(combo)
        total += combo.price
    }
    
    func hide(){
        self.dismiss(animated: true, completion: nil)
    }
    
    let prefId = "150216849-ceed1ee4-8ab9-4449-869f-f4a8565d386f"
    
    func startCheckout(){
        
        let checkout = MPFlowBuilder.startCheckoutViewController(prefId,callback: { (payment : Payment) in
            self.displayPaymentInfo(payment: payment)
        })
        
        self.present(checkout, animated: true, completion: {
            
        })
    }

    func displayPaymentInfo(payment : Payment){
        
        _ = "id : " + String(payment._id) + ",status : " + payment.status + ",status detail : " + payment.statusDetail
        
        
        let sellersView = self.storyboard?.instantiateViewController(withIdentifier: "sellersController")
        
        Ticket.lastTicket = Ticket(idNumber: payment._id, seller: seller! , status: payment.status)
        let ticketView = storyboard?.instantiateViewController(withIdentifier: "ticketController") as! TicketViewController
        self.navigationController?.setViewControllers([sellersView!,ticketView], animated: false)
    }
}

extension PurchaseViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseCombos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comboCell", for: indexPath)
        let currentCombo = purchaseCombos[indexPath.row]
        cell.textLabel?.text = currentCombo.name
        cell.detailTextLabel?.text = currentCombo.price.asLocaleCurrency
        return cell
    }
}

