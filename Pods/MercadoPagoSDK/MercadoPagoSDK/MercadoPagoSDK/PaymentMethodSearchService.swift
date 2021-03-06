  //
//  PaymentMethodSearchService.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 15/1/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


open class PaymentMethodSearchService: MercadoPagoService {
    
    open let MP_SEARCH_PAYMENTS_URI = MercadoPago.MP_ENVIROMENT + "/payment_methods/search/options"
    //public let MP_SEARCH_PAYMENTS_URI = "/payment_methods/search/options"
    
    public init(){
        super.init(baseURL: MercadoPago.MP_API_BASE_URL)
    }
    
    open func getPaymentMethods(_ amount : Double, customerEmail : String? = nil, customerId : String? = nil, excludedPaymentTypeIds : Set<String>?, excludedPaymentMethodIds : Set<String>?, success: @escaping (_ paymentMethodSearch: PaymentMethodSearch) -> Void, failure: @escaping ((_ error: NSError) -> Void)) {
        var params = "public_key=" + MercadoPagoContext.publicKey() + "&amount=" + String(amount)
        
        if excludedPaymentTypeIds != nil && excludedPaymentTypeIds?.count > 0 {
            let excludedPaymentTypesParams = excludedPaymentTypeIds!.map({$0}).joined(separator: ",")
            params = params + "&excluded_payment_types=" + String(excludedPaymentTypesParams).trimSpaces()
        }
        
        if excludedPaymentMethodIds != nil && excludedPaymentMethodIds!.count > 0 {
            let excludedPaymentMethodsParams = excludedPaymentMethodIds!.joined(separator: ",")
            params = params + "&excluded_payment_methods=" + excludedPaymentMethodsParams.trimSpaces()
        }
        
        if customerEmail != nil && customerEmail!.characters.count > 0 {
            params = params + "&email=" + customerEmail!
        }
        
        if customerId != nil && customerId!.characters.count > 0 {
            params = params + "&customer_id=" + customerId!
        }
        
        self.request(uri: MP_SEARCH_PAYMENTS_URI, params: params, body: nil, method: "GET", success: { (jsonResult) -> Void in
            
            if let paymentSearchDic = jsonResult as? NSDictionary {
                if paymentSearchDic["error"] != nil {
                    failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se ha podido obtener los métodos de pago".localized]))
                } else {
                    if paymentSearchDic.allKeys.count > 0 {
                        let paymentSearch = PaymentMethodSearch.fromJSON(jsonResult as! NSDictionary)
                        success(paymentSearch)
                    } else {
                        failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: [NSLocalizedDescriptionKey : "Ha ocurrido un error".localized, NSLocalizedFailureReasonErrorKey : "No se ha podido obtener los métodos de pago".localized]))
                    }
                }
            }
            
            },  failure: { (error) -> Void in
                failure(NSError(domain: "mercadopago.sdk.PaymentMethodSearchService.getPaymentMethods", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Hubo un error".localized, NSLocalizedFailureReasonErrorKey : "Verifique su conexión a ineternet e intente nuevamente".localized]))
        })
    }
    
}
