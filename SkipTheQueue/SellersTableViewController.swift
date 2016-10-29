//
//  SellersTableViewController.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 28/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import CoreLocation

class SellersTableViewController: UITableViewController {
    
    
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()
    
    var sellers:[Seller] = [Seller]()
    var ref: FIRDatabaseReference!
    var locationManager:CLLocationManager!
    var userCoord:CLLocation?
    var sellersImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDatabase()
        
        self.setLoadingScreen()
        
        self.tableView.tableFooterView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Ticket", style: .plain, target: self, action: #selector(showLastTicket))
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sellers.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sellerCell", for: indexPath) as! SellerTableViewCell

        cell.nameLabel.text = sellers[indexPath.row].email
        cell.distanceLabel.text = getDistance(sellerCoor: sellers[indexPath.row].coord)
        cell.imageSeller.imageFromServerURL(urlString: sellers[indexPath.row].imageUrl)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuController = storyboard?.instantiateViewController(withIdentifier: "menuController") as! MenuTableViewController
        menuController.sellerSelected = sellers[indexPath.row]
        self.navigationController!.pushViewController(menuController, animated: true)
    }
    
    func showLastTicket(){
        if Ticket.lastTicket != nil {
            let ticketView = storyboard?.instantiateViewController(withIdentifier: "ticketController") as! TicketViewController
            let nav = UINavigationController(rootViewController: ticketView)
            self.present(nav, animated: true, completion: nil)
        } else {
            self.alert(message: "No tienes ultimo ticket")
        }
    }
    func getImages(){
        
        for (index,seller) in sellers.enumerated() {
            let imageURL = NSURL(string: seller.imageUrl)
            let imagedData = NSData(contentsOf: imageURL! as URL)
            if imagedData != nil {
                sellersImages.insert(UIImage(data:imagedData as! Data)!, at: index)
            }

        }
    }

    func getDistance(sellerCoor:CLLocation)-> String{
        if let coord = userCoord {
            let distanceInMeters = sellerCoor.distance(from: coord)
            let roundDistance = distanceInMeters.rounded()
            if roundDistance > 1000 {
                let kmDistance = (roundDistance/1000).rounded()
                return String(kmDistance) + "km"
            } else {
                return String(roundDistance) + "m"
            }
        } else {
            return "0m"
        }
    }
    
    func configureDatabase() {
        self.ref = FIRDatabase.database().reference()
        
        self.ref.child("Vendedores").child("sellers").observe(.value, with: { (snapshot) in
            let sellersResponce = snapshot.value as! [NSDictionary]
            var newSellers = [Seller]()
            for sellerDict in sellersResponce {
                newSellers.append(Seller(dict: sellerDict))
            }
            self.sellers = newSellers
            self.removeLoadingScreen()
            self.tableView.reloadData()
            }) { (error) in
                print(error)
        }
    }
    
    
    // Set the activity indicator into the main view
    private func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.tableView.frame.width / 2) - (width / 2)
        let y = (self.tableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Cargando..."
        self.loadingLabel.frame = CGRect(x:0, y:0, width:140, height:30)
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.frame = CGRect(x:0, y:0, width:30, height:30)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.tableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    private func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
        
    }
}

extension SellersTableViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        let coord = locationObj.coordinate
        self.userCoord = locationObj
        print(coord.latitude)
        print(coord.longitude)
        self.tableView.reloadData()
        

    }
    
}
