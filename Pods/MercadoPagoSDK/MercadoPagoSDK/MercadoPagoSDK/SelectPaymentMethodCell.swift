//
//  SelectPaymentMethodCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 12/2/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class SelectPaymentMethodCell: UITableViewCell {

    @IBOutlet weak var selectPaymentMethodLabel: MPLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectPaymentMethodLabel.text = "Seleccione método de pago...".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
