//
//  MPFlowBuilder.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 1/7/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

open class MPFlowBuilder : NSObject {
    
    @available(*, deprecated: 2.0.0, message: "Use startCheckoutViewController instead")
    open class func startVaultViewController(_ amount: Double, paymentPreference : PaymentPreference? = nil,
                            callback: @escaping (_ paymentMethod: PaymentMethod, _ tokenId: String?, _ issuer: Issuer?, _ installments: Int) -> Void) -> VaultViewController {
    MercadoPagoContext.initFlavor3()
        return VaultViewController(amount: amount, paymentPreference: paymentPreference, callback: callback)
        
    }
    
    open class func startCheckoutViewController(_ preferenceId: String,
                        callback: @escaping (Payment) -> Void,
                        callbackCancel : ((Void) -> Void)? = nil) -> MPNavigationController {
        
        MercadoPagoContext.initFlavor3()
        let checkoutVC = CheckoutViewController(preferenceId: preferenceId,
                                                callback: { (payment : Payment) -> Void in callback(payment) },
                                                callbackCancel :callbackCancel)
        return MPFlowController.createNavigationControllerWith(checkoutVC)
    }
    

    open class func startPaymentVaultViewController(_ amount: Double, paymentPreference : PaymentPreference? = nil,
                                                      callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost : PayerCost?) -> Void,
                                                      callbackCancel : ((Void) -> Void)? = nil) -> MPNavigationController {
        
        MercadoPagoContext.initFlavor2()
        let paymentVault = PaymentVaultViewController(amount: amount, paymentPreference : paymentPreference, callback: callback)
            paymentVault.viewModel.callback = {(paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void in
                                    paymentVault.dismiss(animated: true, completion: { () -> Void in
                                            callback(paymentMethod, token, issuer, payerCost)}
                                    )}
        paymentVault.modalTransitionStyle = .crossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }

    
    open class func startPaymentVaultViewController(_ amount : Double, paymentPreference : PaymentPreference? = nil, paymentMethodSearch : PaymentMethodSearch, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) -> MPNavigationController {
        MercadoPagoContext.initFlavor2()
        var paymentVault : PaymentVaultViewController?
        paymentVault = PaymentVaultViewController(amount: amount, paymentPreference: paymentPreference, paymentMethodSearch: paymentMethodSearch, callback: {(paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost : PayerCost?) -> Void in
                paymentVault!.dismiss(animated: true, completion: { () -> Void in
                callback(paymentMethod, token, issuer, payerCost)}
            )}, callbackCancel: callbackCancel)
        paymentVault!.modalTransitionStyle = .crossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault!)
    }
    
    internal class func startPaymentVaultInCheckout(_ amount: Double, paymentPreference: PaymentPreference?, paymentMethodSearch : PaymentMethodSearch,
                                                    callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost : PayerCost?) -> Void,
                                                    callbackCancel : ((Void) -> Void)? = nil) -> MPNavigationController {
        
        MercadoPagoContext.initFlavor2()
        let paymentVault = PaymentVaultViewController(amount: amount, paymentPreference: paymentPreference, paymentMethodSearchItem: paymentMethodSearch.groups, paymentMethods: paymentMethodSearch.paymentMethods, tintColor: true,
                                                      callback: callback, callbackCancel : callbackCancel)
        paymentVault.modalTransitionStyle = .crossDissolve
        return MPFlowController.createNavigationControllerWith(paymentVault)
    }

    
    open class func startCardFlow(_ paymentPreference: PaymentPreference? = nil  , amount: Double, cardInformation : CardInformation? = nil, paymentMethods : [PaymentMethod]? = nil, token: Token? = nil, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token? ,  _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) -> MPNavigationController {
        MercadoPagoContext.initFlavor2()
        var cardVC : MPNavigationController?
        var ccf : CardFormViewController = CardFormViewController()
        
        var currentCallbackCancel : ((Void) -> Void)
        if (callbackCancel == nil){
            currentCallbackCancel = { cardVC?.dismiss(animated: true, completion: { () -> Void in })}
        } else {
            currentCallbackCancel = callbackCancel!
        }
        cardVC = MPStepBuilder.startCreditCardForm(paymentPreference, amount: amount, cardInformation : cardInformation, paymentMethods : paymentMethods, token: token, callback: { (paymentMethod, token, issuer) -> Void in
            
            MPServicesBuilder.getInstallments(token!.firstSixDigit, amount: amount, issuer: issuer, paymentMethodId: paymentMethod._id, success: { (installments) -> Void in
                let payerCostSelected = paymentPreference?.autoSelectPayerCost(installments![0].payerCosts)
                    if(payerCostSelected == nil){ // Si tiene una sola opcion de cuotas
                        let pcvc = MPStepBuilder.startPayerCostForm(paymentMethod, issuer: issuer, token: token!, amount:amount, paymentPreference: paymentPreference, installment:installments![0] ,callback: { (payerCost) -> Void in
                            callback(paymentMethod, token!, issuer, payerCost)
                        })
                        pcvc.callbackCancel = currentCallbackCancel
                        
                        ccf.navigationController!.pushViewController(pcvc, animated: false)

                    }else{
                         callback(paymentMethod, token!, issuer, payerCostSelected)
                    }

                
                }, failure: { (error) -> Void in
                     (ccf.navigationController as! MPNavigationController).hideLoading()
            })

            
            }, callbackCancel : currentCallbackCancel)
    
        ccf = cardVC?.viewControllers[0] as! CardFormViewController
    
      
        cardVC!.modalTransitionStyle = .crossDissolve
        return cardVC!

    }


}
