//
//  PaymentMethodSelectedTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class PaymentMethodSelectedTableViewCell: UITableViewCell {

    @IBOutlet weak var paymentIcon: UIImageView!
    
    @IBOutlet weak var paymentDescription: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fillRowWithPaymentMethod(_ paymentMethod : PaymentMethod, lastFourDigits : String) {
        self.paymentIcon.image = MercadoPago.getImageFor(paymentMethod, forCell: true)
        self.paymentDescription.text = "terminada en ".localized + lastFourDigits
        //ViewUtils.drawBottomLine(y : 47, width: self.view.bounds.width, inView: self)
    }
    
}
