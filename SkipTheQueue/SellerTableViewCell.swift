//
//  SellerTableViewCell.swift
//  SkipTheQueue
//
//  Created by Franco Fadini on 28/10/16.
//  Copyright © 2016 Franco Fadini. All rights reserved.
//

import UIKit

class SellerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var imageSeller: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setImage(urlString:String){
        
        let url = NSURL(string: urlString)!
        let request = URLRequest(url:url as URL)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.sync() {
                self.imageView?.image = UIImage(data: data)
            }
            
        }
        task.resume()
    }

}
