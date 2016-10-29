//
//  MenuTableViewController.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 28/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {
    
    var sellerSelected:Seller?
    var menu = [Combo]()
    var purchaseController:PurchaseViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.menu = sellerSelected!.menu
        purchaseController = storyboard!.instantiateViewController(withIdentifier: "purchaseController") as? PurchaseViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCellFromMenu", for: indexPath) as! SellerTableViewCell
            cell.nameLabel.text = sellerSelected!.email
            cell.imageSeller.imageFromServerURL(urlString: (sellerSelected?.imageUrl)!)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "comboCell", for: indexPath)
            let currentCombo = menu[indexPath.row-1]
            cell.textLabel?.text = currentCombo.name
            cell.detailTextLabel?.text = currentCombo.price.asLocaleCurrency
            return cell
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row > 0 {
            if purchaseController?.seller == nil {
                purchaseController?.seller = sellerSelected
            }
            purchaseController?.addCombo(menu[indexPath.row-1])
            let nav = UINavigationController(rootViewController: purchaseController!)
            self.navigationController?.present(nav, animated: true, completion: nil)
        }
    }
    
    
    
}
