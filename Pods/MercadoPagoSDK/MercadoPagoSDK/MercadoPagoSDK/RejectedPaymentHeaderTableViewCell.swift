//
//  RejectedPaymentTableViewCell.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 9/5/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

class RejectedPaymentHeaderTableViewCell: UITableViewCell, CongratsFillmentDelegate {
    
    
    @IBOutlet weak var title: MPLabel!
    
    @IBOutlet weak var subtitle: MPLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.title.addCharactersSpacing(-0.4)
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.6

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillCell(_ payment : Payment, paymentMethod : PaymentMethod, callback : ((Void) -> Void)?) -> UITableViewCell {
        
        var title = (payment.statusDetail + "_title")
        if !title.existsLocalized() {
            title = "Uy, no pudimos procesar el pago".localized
        }
        
        let titleWithParams = (title.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethod.name)")
        self.title.text = titleWithParams
        
        
        
        
       
        var subtitle = (payment.statusDetail + "_subtitle_" + paymentMethod.paymentTypeId)
        if !subtitle.existsLocalized() {
            subtitle =  ("Algún dato de tu %1$s es incorrecto.".localized as NSString).replacingOccurrences(of: "%1$s", with: paymentMethod.name)
        }
        
        let subtitleWithParams = (subtitle.localized as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethod.name)")
        self.subtitle.text = subtitleWithParams
        return self
    }
 
    func getCellHeight(_ payment : Payment, paymentMethod : PaymentMethod) -> CGFloat {
        
        var constraintSize = CGSize()
        let screenSize: CGRect = UIScreen.main.bounds
        constraintSize.width = screenSize.width - 46
        
        let attributes = [NSFontAttributeName: UIFont(name: MercadoPago.DEFAULT_FONT_NAME, size: 14) ?? UIFont.systemFont(ofSize: 14)]
        
        let subtitle = ((payment.statusDetail + "_subtitle_" + paymentMethod.paymentTypeId).localized  as NSString).replacingOccurrences(of: "%0", with: "\(paymentMethod.name)")

        let frame = (subtitle as NSString).boundingRect(with: constraintSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        let stringSize = frame.size
        return 180 + stringSize.height
        
        
    }
    
}
