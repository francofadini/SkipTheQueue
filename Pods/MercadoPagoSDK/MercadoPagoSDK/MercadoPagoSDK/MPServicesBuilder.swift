//
//  MPServicesBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation


open class MPServicesBuilder : NSObject {
   
    static let MP_PAYMENTS_URI = MercadoPago.MP_ENVIROMENT + "/checkout/payments"


    open class func createNewCardToken(_ cardToken : CardToken,
                                         success:@escaping (_ token : Token?) -> Void,
                                         failure: ((_ error: NSError) -> Void)?) {
        
    MercadoPagoContext.initFlavor1()
    MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CREATE_CARD_TOKEN", result: nil)
      
        cardToken.device = Device()
        let service = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.getToken(public_key: MercadoPagoContext.publicKey(), cardToken: cardToken, success: {(jsonResult: AnyObject?) -> Void in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                    MPTracker.trackCreateToken(MercadoPagoContext.sharedInstance, token: token?._id)
                    success(token)
                } else {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.createNewCardToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: Any]))
                    }
                }
            }
            }, failure: failure)
    }
    
    open class func createToken(_ savedCardToken : SavedCardToken,
                        success: @escaping (_ token : Token?) -> Void,
                        failure: ((_ error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CREATE_SAVED_TOKEN", result: nil)
            savedCardToken.device = Device()
            let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getToken(public_key: MercadoPagoContext.publicKey(), savedCardToken: savedCardToken, success: {(jsonResult: AnyObject?) -> Void in
                var token : Token? = nil
                if let tokenDic = jsonResult as? NSDictionary {
                    if tokenDic["error"] == nil {
                        token = Token.fromJSON(tokenDic)
                        MPTracker.trackCreateToken(MercadoPagoContext.sharedInstance, token: token?._id)
                        success(token)
                    } else {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: Any]))
                        }
                    }
                }
                }, failure: failure)

    }
    
    open class func cloneToken(_ token : Token,
                                 securityCode: String,
                                  success: @escaping (_ token : Token?) -> Void,
                                  failure: ((_ error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CLONE_TOKEN", result: nil)
        let service : GatewayService = GatewayService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.cloneToken(public_key: MercadoPagoContext.publicKey(), token: token,securityCode: securityCode, success:{(jsonResult: AnyObject?) -> Void in
            var token : Token? = nil
            if let tokenDic = jsonResult as? NSDictionary {
                if tokenDic["error"] == nil {
                    token = Token.fromJSON(tokenDic)
                    MPTracker.trackCreateToken(MercadoPagoContext.sharedInstance, token: token?._id)
                    success(token)
                } else {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.createToken", code: MercadoPago.ERROR_API_CODE, userInfo: tokenDic as! [AnyHashable: Any]))
                    }
                }
            }
            }, failure: failure)
        
        
    }

    
    
    open class func getPaymentMethods(
                        _ success: @escaping (_ paymentMethods: [PaymentMethod]?) -> Void,
                        failure: ((_ error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_PAYMENT_METHODS", result: nil)
            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getPaymentMethods(public_key: MercadoPagoContext.publicKey(), success: {(jsonResult: AnyObject?) -> Void in
                if let errorDic = jsonResult as? NSDictionary {
                    if errorDic["error"] != nil {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.getPaymentMethods", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: Any]))
                        }
                    }
                } else {
                    let paymentMethods = jsonResult as? NSArray
                    var pms : [PaymentMethod] = [PaymentMethod]()
                    if paymentMethods != nil {
                        for i in 0..<paymentMethods!.count {
                            if let pmDic = paymentMethods![i] as? NSDictionary {
                                pms.append(PaymentMethod.fromJSON(pmDic))
                            }
                        }
                    }
                    success(pms)
                }
                }, failure: failure)
     
    }
    
    open class func getIdentificationTypes(
                        _ success: @escaping (_ identificationTypes: [IdentificationType]?) -> Void,
                        failure: ((_ error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_IDENTIFICATION_TYPES", result: nil)
             let service : IdentificationService = IdentificationService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIdentificationTypes(public_key: MercadoPagoContext.publicKey(), privateKey: MercadoPagoContext.privateKey(), success: {(jsonResult: AnyObject?) -> Void in
                
                if let error = jsonResult as? NSDictionary {
                    if (error["status"]! as? Int) == 404 {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.getIdentificationTypes", code: MercadoPago.ERROR_API_CODE, userInfo: error as! [AnyHashable: Any]))
                        }
                    }
                } else {
                    let identificationTypesResult = jsonResult as? NSArray?
                    var identificationTypes : [IdentificationType] = [IdentificationType]()
                    if identificationTypesResult != nil {
                        for i in 0 ..< identificationTypesResult!!.count {
                            if let identificationTypeDic = identificationTypesResult!![i] as? NSDictionary {
                                identificationTypes.append(IdentificationType.fromJSON(identificationTypeDic))
                            }
                        }
                    }
                    success(identificationTypes)
                }
                }, failure: failure)
       
    }
    
    open class func getInstallments(_ bin: String? = nil, amount: Double, issuer: Issuer?, paymentMethodId: String,
                                      success: @escaping (_ installments: [Installment]?) -> Void,
                                      failure: @escaping ((_ error: NSError) -> Void)) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_INSTALLMENTS", result: nil)

            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getInstallments(public_key:MercadoPagoContext.publicKey(), bin: bin, amount: amount, issuer_id: issuer?._id, payment_method_id: paymentMethodId, success: success, failure: failure)
        
    }
    
    open class func getIssuers(_ paymentMethod : PaymentMethod, bin: String? = nil, success: @escaping (_ issuers: [Issuer]?) -> Void, failure: ((_ error: NSError) -> Void)?) {
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_ISSUERS", result: nil)

            let service : PaymentService = PaymentService(baseURL: MercadoPago.MP_API_BASE_URL)
            service.getIssuers(public_key: MercadoPagoContext.publicKey(), payment_method_id: paymentMethod._id, bin: bin, success: {(jsonResult: AnyObject?) -> Void in

                if let errorDic = jsonResult as? NSDictionary {
                    if errorDic["error"] != nil {
                        if failure != nil {
                            failure!(NSError(domain: "mercadopago.sdk.getIssuers", code: MercadoPago.ERROR_API_CODE, userInfo: errorDic as! [AnyHashable: Any]))
                        }
                    }
                } else {
                    let issuersArray = jsonResult as? NSArray
                    var issuers : [Issuer] = [Issuer]()
                    if issuersArray != nil {
                        for i in 0..<issuersArray!.count {
                            if let issuerDic = issuersArray![i] as? NSDictionary {
                                issuers.append(Issuer.fromJSON(issuerDic))
                            }
                        }
                    }
                    success(issuers)
                }
                }, failure: failure)
        
    }
    
    open class func getPromos(
                        _ success: @escaping (_ promos: [Promo]?) -> Void,
                        failure: ((_ error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_BANK_DEALS", result: nil)
        
        let service : PromosService = PromosService(baseURL: MercadoPago.MP_API_BASE_URL)
        service.getPromos(public_key: MercadoPagoContext.publicKey(), success: { (jsonResult) -> Void in
            let promosArray = jsonResult as? NSArray?
            var promos : [Promo] = [Promo]()
            if promosArray != nil {
                for i in 0 ..< promosArray!!.count {
                    if let promoDic = promosArray!![i] as? NSDictionary {
                        promos.append(Promo.fromJSON(promoDic))
                    }
                }
            }
            success(promos)
            }, failure: failure)
        
    }

        
    open class func createPayment(_ merchantBaseUrl : String, merchantPaymentUri : String, payment : MerchantPayment,
                         success: @escaping (_ payment: Payment) -> Void,
                         failure: ((_ error: NSError) -> Void)?) {
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "CREATE_PAYMENT", result: nil)
        let service : MerchantService = MerchantService()
        service.createPayment(payment: payment, success: {(jsonResult: AnyObject?) -> Void in
            var payment : Payment? = nil
            
            
            
            if let paymentDic = jsonResult as? NSDictionary {
                if paymentDic["error"] != nil {
                    if failure != nil {
                        failure!(NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_API_CODE, userInfo: paymentDic as! [AnyHashable: Any]))
                    }
                } else {
                    if paymentDic.allKeys.count > 0 {
                        payment = Payment.fromJSON(paymentDic)
                        success(payment!)
                    } else {
                        failure!(NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_PAYMENT, userInfo: ["message": "PAYMENT_ERROR".localized]))
                    }
                    
                }
            } else {
                if failure != nil {
                    failure!(NSError(domain: "mercadopago.sdk.merchantServer.createPayment", code: MercadoPago.ERROR_UNKNOWN_CODE, userInfo: ["message": "Response cannot be decoded"]))
                }
            }
            }, failure: failure)
    }


    open class func searchPaymentMethods(_ amount : Double, excludedPaymentTypeIds : Set<String>?, excludedPaymentMethodIds : Set<String>?, success: @escaping (PaymentMethodSearch) -> Void, failure: ((_ error: NSError) -> Void)?) {
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_PAYMENT_METHOD_SEARCH", result: nil)
        let paymentMethodSearchService = PaymentMethodSearchService()
        paymentMethodSearchService.getPaymentMethods(amount, excludedPaymentTypeIds: excludedPaymentTypeIds, excludedPaymentMethodIds: excludedPaymentMethodIds, success: success, failure: failure!)
    
    }
    
    open class func getInstructions(_ paymentId : Int, paymentTypeId: String? = "",
                        success : @escaping (_ instructionsInfo : InstructionsInfo) -> Void,
                        failure: ((_ error: NSError) -> Void)?) {
        
    MercadoPagoContext.initFlavor1()
    MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_INSTRUCTIONS", result: nil)
        let instructionsService = InstructionsService()
        instructionsService.getInstructions(paymentId, paymentTypeId: paymentTypeId, success:  { (instructionsInfo : InstructionsInfo) -> Void in
            success(instructionsInfo)
        }, failure : failure)
    }
    
    open class func getPreference(_ preferenceId : String,
                         success : @escaping (_ preference : CheckoutPreference) -> Void,
                         failure: @escaping ((_ error: NSError) -> Void)){
        
        MercadoPagoContext.initFlavor1()
        MPTracker.trackEvent(MercadoPagoContext.sharedInstance, action: "GET_PREFERENCE", result: nil)
        let preferenceService = PreferenceService()
        preferenceService.getPreference(preferenceId, success: { (preference : CheckoutPreference) in
            MercadoPagoContext.setSiteID(preference.siteId)
            success(preference)
            }, failure: failure)
    }

}



