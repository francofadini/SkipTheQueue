 //
//  PaymentVaultViewController.swift
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



open class PaymentVaultViewController: MercadoPagoUIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let VIEW_CONTROLLER_NIB_NAME : String = "PaymentVaultViewController"
    
    var merchantBaseUrl : String!
    var merchantAccessToken : String!
    var publicKey : String!
    var currency : Currency!

    
    var defaultInstallments : Int?
    var installments : Int?
    var viewModel : PaymentVaultViewModel!

    var bundle = MercadoPago.getBundle()
    
    fileprivate var tintColor = true
    
    @IBOutlet weak var paymentsTable: UITableView!
    

    
    public init(amount : Double, paymentPreference : PaymentPreference?, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void) {
        super.init(nibName: PaymentVaultViewController.VIEW_CONTROLLER_NIB_NAME, bundle: bundle)
        self.initCommon()
        self.initViewModel(amount, paymentPreference : paymentPreference, callback: callback)
        
       
        
    }
    
    public init(amount : Double, paymentPreference : PaymentPreference? = nil, paymentMethodSearch : PaymentMethodSearch,
                callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void,
                callbackCancel : ((Void) -> Void)? = nil) {
        super.init(nibName: PaymentVaultViewController.VIEW_CONTROLLER_NIB_NAME, bundle: bundle)
        self.initCommon()
        self.initViewModel(amount, paymentPreference: paymentPreference, customerPaymentMethods: paymentMethodSearch.customerPaymentMethods, paymentMethodSearchItem : paymentMethodSearch.groups, paymentMethods: paymentMethodSearch.paymentMethods, callback: callback)
        
        self.callbackCancel = callbackCancel
        
    }
    
    internal init(amount: Double, paymentPreference : PaymentPreference?, paymentMethodSearchItem : [PaymentMethodSearchItem]? = nil, paymentMethods: [PaymentMethod], title: String? = "", tintColor : Bool = false, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void, callbackCancel : ((Void) -> Void)? = nil) {
        
        super.init(nibName: PaymentVaultViewController.VIEW_CONTROLLER_NIB_NAME, bundle: bundle)
        self.initCommon()
        self.initViewModel(amount, paymentPreference: paymentPreference, paymentMethodSearchItem: paymentMethodSearchItem, paymentMethods: paymentMethods, callback : callback)
        
        //Installment > 0
        
        //Vaidar que no excluyo todos los payment method
        
        self.title = title
        self.tintColor = tintColor
        
        self.callbackCancel = callbackCancel
        
        
    }
    
    fileprivate func initCommon(){
        
        self.merchantBaseUrl = MercadoPagoContext.baseURL()
        self.merchantAccessToken = MercadoPagoContext.merchantAccessToken()
        self.publicKey = MercadoPagoContext.publicKey()
        self.currency = MercadoPagoContext.getCurrency()
    }
    
    fileprivate func initViewModel(_ amount : Double, paymentPreference : PaymentPreference?, customerPaymentMethods: [CardInformation]? = nil, paymentMethodSearchItem : [PaymentMethodSearchItem]? = nil, paymentMethods: [PaymentMethod]? = nil, callback: @escaping (_ paymentMethod: PaymentMethod, _ token: Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void){
        self.viewModel = PaymentVaultViewModel(amount: amount, paymentPrefence: paymentPreference)
        
        self.viewModel.currentPaymentMethodSearch = paymentMethodSearchItem
        self.viewModel.paymentMethods = paymentMethods
        self.viewModel.customerCards = customerPaymentMethods
        self.viewModel.callback = callback
    }

    
    required  public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.title == nil || self.title!.isEmpty {
            self.title = "¿Cómo quieres pagar?".localized
        }
        
        self.paymentsTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.paymentsTable.bounds.size.width, height: 0.01))
        self.registerAllCells()
    
        if callbackCancel == nil {
            self.callbackCancel = {(Void) -> Void in
                if self.navigationController?.viewControllers[0] == self {
                    self.dismiss(animated: true, completion: {
                        
                    })
                } else {
                    self.navigationController!.popViewController(animated: true)
                }
            }
        } else {
            self.callbackCancel = callbackCancel
        }

        
        
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem!.action = #selector(invokeCallbackCancel)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getCustomerCards()
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.viewModel.getCustomerPaymentMethodsToDisplayCount()
        default:
            return self.viewModel.currentPaymentMethodSearch.count
        }
    }
    
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.getCustomerPaymentMethodsToDisplayCount() > 0 ? 16 : 0
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return self.viewModel.getCustomerCardRowHeight()
        case 1:
           return self.viewModel.getPaymentMethodRowHeight((indexPath as NSIndexPath).row)
        default:
                return 100
        }
        
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 && self.viewModel.getCustomerPaymentMethodsToDisplayCount() > 0 {
            let customerPaymentMethodCell = self.paymentsTable.dequeueReusableCell(withIdentifier: "customerPaymentMethodCell") as! CustomerPaymentMethodCell
            customerPaymentMethodCell.fillRowWithCustomerPayment(self.viewModel.customerCards![(indexPath as NSIndexPath).row])
            return customerPaymentMethodCell
        }
        
        
        let currentPaymentMethod = self.viewModel.currentPaymentMethodSearch[(indexPath as NSIndexPath).row]
                
        let paymentMethodCell = getCellFor(currentPaymentMethod)
        // Add shadow effect to last cell in table
        if ((indexPath as NSIndexPath).row == self.viewModel.currentPaymentMethodSearch.count - 1) {
            paymentMethodCell.clipsToBounds = false
            paymentMethodCell.layer.masksToBounds = false
            paymentMethodCell.layer.shadowOffset = CGSize(width: 0, height: 1)
            paymentMethodCell.layer.shadowColor = UIColor(red: 153, green: 153, blue: 153).cgColor
            paymentMethodCell.layer.shadowRadius = 1
            paymentMethodCell.layer.shadowOpacity = 0.6
        }
        return paymentMethodCell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            if self.viewModel!.getCustomerPaymentMethodsToDisplayCount() > 0 {
                let customerCardSelected = self.viewModel.customerCards![(indexPath as NSIndexPath).row] as CardInformation
                let paymentMethodSelected = Utils.findPaymentMethod(self.viewModel.paymentMethods, paymentMethodId: customerCardSelected.getPaymentMethodId())
               customerCardSelected.setupPaymentMethodSettings(paymentMethodSelected.settings)
                let cardFlow = MPFlowBuilder.startCardFlow(amount: self.viewModel.amount, cardInformation : customerCardSelected, callback: { (paymentMethod, token, issuer, payerCost) in
                    self.viewModel!.callback!(paymentMethod, token, issuer, payerCost)
                    }, callbackCancel: {
                        self.navigationController!.popToViewController(self, animated: true)
                })
                self.navigationController?.pushViewController(cardFlow.viewControllers[0], animated: true)
            }
        default:
            let paymentSearchItemSelected = self.viewModel.currentPaymentMethodSearch[(indexPath as NSIndexPath).row]
            self.paymentsTable.deselectRow(at: indexPath, animated: true)
            if (paymentSearchItemSelected.children.count > 0) {
                let paymentVault = PaymentVaultViewController(amount: self.viewModel.amount, paymentPreference: self.viewModel.paymentPreference, paymentMethodSearchItem: paymentSearchItemSelected.children, paymentMethods : self.viewModel.paymentMethods, title:paymentSearchItemSelected.childrenHeader, callback: { (paymentMethod: PaymentMethod, token: Token?, issuer: Issuer?, payerCost: PayerCost?) -> Void in
                    self.viewModel.callback!(paymentMethod, token, issuer, payerCost)
                })
                paymentVault.viewModel!.isRoot = false
                self.navigationController!.pushViewController(paymentVault, animated: true)
            } else {
                self.viewModel.optionSelected(paymentSearchItemSelected, navigationController: self.navigationController!, cancelPaymentCallback: cardFormCallbackCancel())
            }

        }
    }
    
    fileprivate func cardFormCallbackCancel() -> ((Void) -> (Void)) {
        return { Void -> (Void) in
            if self.viewModel.currentPaymentMethodSearch.count > 1 {
                self.navigationController!.popToViewController(self, animated: true)
            } else {
                self.navigationController!.popToViewController(self, animated: true)
                self.callbackCancel!()
            }
        }
    }
    
    fileprivate func getCustomerCards(){
        if self.viewModel!.shouldGetCustomerCardsInfo() {
            MerchantServer.getCustomer({ (customer: Customer) -> Void in
                self.viewModel.customerCards = customer.cards
                self.loadPaymentMethodSearch()
                
                }, failure: { (error: NSError?) -> Void in
                    print(error)
            })
        } else {
            self.loadPaymentMethodSearch()
        }
    }
    
    fileprivate func loadPaymentMethodSearch(){
        
        if self.viewModel.currentPaymentMethodSearch == nil {
            self.showLoading()
            MPServicesBuilder.searchPaymentMethods(self.viewModel.amount, excludedPaymentTypeIds: viewModel.getExcludedPaymentTypeIds(), excludedPaymentMethodIds: viewModel.getExcludedPaymentMethodIds(), success: { (paymentMethodSearchResponse: PaymentMethodSearch) -> Void in
                
                self.viewModel.setPaymentMethodSearch(paymentMethodSearchResponse)
                self.hideLoading()
                self.loadPaymentMethodSearch()
                
                }, failure: { (error) -> Void in
                    self.hideLoading()
                    self.requestFailure(error, callback: {
                        self.navigationController!.dismiss(animated: true, completion: {})
                        }, callbackCancel: {
                            self.invokeCallbackCancel()
                    })
            })
            
        } else {
            
            if self.viewModel.currentPaymentMethodSearch.count == 1 && self.viewModel.currentPaymentMethodSearch[0].children.count > 0 {
                self.viewModel.currentPaymentMethodSearch = self.viewModel.currentPaymentMethodSearch[0].children
            }
            
            if self.viewModel.currentPaymentMethodSearch.count == 1 {
                self.viewModel.optionSelected(self.viewModel.currentPaymentMethodSearch[0],navigationController: self.navigationController!, cancelPaymentCallback: self.cardFormCallbackCancel(), animated: false)
            } else {
                self.paymentsTable.delegate = self
                self.paymentsTable.dataSource = self
                self.paymentsTable.reloadData()
            }
        }
    }
    
    
    fileprivate func getCellFor(_ currentPaymentMethodItem : PaymentMethodSearchItem) -> UITableViewCell {
        if currentPaymentMethodItem.showIcon {
            let iconImage = MercadoPago.getImage(currentPaymentMethodItem.idPaymentMethodSearchItem)
            let tintColor = self.tintColor && (!currentPaymentMethodItem.isPaymentMethod() || currentPaymentMethodItem.isBitcoin())
            
            if iconImage != nil {
                if currentPaymentMethodItem.isPaymentMethod() && !currentPaymentMethodItem.isBitcoin() {
                    if currentPaymentMethodItem.comment != nil && currentPaymentMethodItem.comment!.characters.count > 0 {
                        let offlinePaymentCell = self.paymentsTable.dequeueReusableCell(withIdentifier: "offlinePaymentMethodCell") as! OfflinePaymentMethodCell
                        let description = currentPaymentMethodItem.description ?? ""
                        offlinePaymentCell.fillRowWithPaymentMethod(currentPaymentMethodItem, image: iconImage!, paymentItemDescription: description)
                        return offlinePaymentCell
                    } else {
                        let offlinePaymentCellWithDescription = self.paymentsTable.dequeueReusableCell(withIdentifier: "offlinePaymentWithDescription") as! OfflinePaymentMethodWithDescriptionCell
                        return offlinePaymentCellWithDescription.fillRowWith(currentPaymentMethodItem)
                    }
                }
                let paymentSearchCell = self.paymentsTable.dequeueReusableCell(withIdentifier: "paymentSearchCell") as! PaymentSearchCell
                paymentSearchCell.fillRowWithPayment(currentPaymentMethodItem, iconImage : iconImage!, tintColor: tintColor)
                return paymentSearchCell
            }
        }

        if currentPaymentMethodItem.comment != nil && currentPaymentMethodItem.comment?.characters.count > 0 {
            let paymentSearchTitleAndCommentCell = self.paymentsTable.dequeueReusableCell(withIdentifier: "paymentTitleAndCommentCell") as! PaymentTitleAndCommentViewCell
            paymentSearchTitleAndCommentCell.fillRowWith(currentPaymentMethodItem.description, paymentComment: currentPaymentMethodItem.comment!)
            return paymentSearchTitleAndCommentCell
        }
        
        let paymentSearchCell = self.paymentsTable.dequeueReusableCell(withIdentifier: "paymentSearchTitleCell") as! PaymentTitleViewCell
        paymentSearchCell.paymentTitle.text = currentPaymentMethodItem.description
        return paymentSearchCell

    }

    fileprivate func registerAllCells(){
        let paymentMethodSearchNib = UINib(nibName: "PaymentSearchCell", bundle: self.bundle)
        let paymentSearchTitleCell = UINib(nibName: "PaymentTitleViewCell", bundle: self.bundle)
        let offlinePaymentMethodCell = UINib(nibName: "OfflinePaymentMethodCell", bundle: self.bundle)
        let preferenceDescriptionCell = UINib(nibName: "PreferenceDescriptionTableViewCell", bundle: self.bundle)
        let paymentTitleAndCommentCell = UINib(nibName: "PaymentTitleAndCommentViewCell", bundle: self.bundle)
        let offlinePaymentWithDescription = UINib(nibName: "OfflinePaymentMethodWithDescriptionCell", bundle: self.bundle)
        let exitButtonCell = UINib(nibName: "ExitButtonTableViewCell", bundle: self.bundle)
        let customerPaymentMethodCell = UINib(nibName: "CustomerPaymentMethodCell", bundle: self.bundle)
        
        self.paymentsTable.register(paymentTitleAndCommentCell, forCellReuseIdentifier: "paymentTitleAndCommentCell")
        self.paymentsTable.register(paymentMethodSearchNib, forCellReuseIdentifier: "paymentSearchCell")
        self.paymentsTable.register(paymentSearchTitleCell, forCellReuseIdentifier: "paymentSearchTitleCell")
        self.paymentsTable.register(offlinePaymentMethodCell, forCellReuseIdentifier: "offlinePaymentMethodCell")
        self.paymentsTable.register(preferenceDescriptionCell, forCellReuseIdentifier: "preferenceDescriptionCell")
        self.paymentsTable.register(offlinePaymentWithDescription, forCellReuseIdentifier: "offlinePaymentWithDescription")
        self.paymentsTable.register(customerPaymentMethodCell, forCellReuseIdentifier: "customerPaymentMethodCell")
        self.paymentsTable.register(exitButtonCell, forCellReuseIdentifier: "exitButtonCell")
        
    }
    
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //En caso de que el vc no sea root
        if (navigationController != nil && navigationController!.viewControllers.count > 1 && navigationController!.viewControllers[0] != self) || (navigationController != nil && navigationController!.viewControllers.count == 1) {
            if self.viewModel!.isRoot {
                self.callbackCancel!()
            }
            return true
        }
        return false
    }

}


class PaymentVaultViewModel : NSObject {
    
    var amount : Double
    var paymentPreference : PaymentPreference?
    
    var customerCards : [CardInformation]?
    var paymentMethods : [PaymentMethod]!
    var currentPaymentMethodSearch : [PaymentMethodSearchItem]!
    
    var callback : ((_ paymentMethod: PaymentMethod, _ token:Token?, _ issuer: Issuer?, _ payerCost: PayerCost?) -> Void)!
    
    internal var isRoot = true
    
    init(amount : Double, paymentPrefence : PaymentPreference?){
        self.amount = amount
        self.paymentPreference = paymentPrefence
    }
    
    func shouldGetCustomerCardsInfo() -> Bool {
        return MercadoPagoContext.isCustomerInfoAvailable() && self.isRoot
    }
    
    func getCustomerPaymentMethodsToDisplayCount() -> Int {
        if (self.customerCards != nil && self.customerCards?.count > 0) {
            return (self.customerCards!.count <= 3 ? self.customerCards!.count : 3)
        }
        return 0
        
    }
    
    func getCustomerCardRowHeight() -> CGFloat {
        return self.getCustomerPaymentMethodsToDisplayCount() > 0 ? CustomerPaymentMethodCell.ROW_HEIGHT : 0
    }
    
    func getPaymentMethodRowHeight(_ rowIndex : Int) -> CGFloat {
        
        let currentPaymentMethodSearchItem = self.currentPaymentMethodSearch[rowIndex]
        if currentPaymentMethodSearchItem.showIcon {
            if currentPaymentMethodSearchItem.isPaymentMethod() && !currentPaymentMethodSearchItem.isBitcoin() {
                if currentPaymentMethodSearchItem.comment != nil && currentPaymentMethodSearchItem.comment!.characters.count > 0 {
                    return OfflinePaymentMethodCell.ROW_HEIGHT
                } else {
                    return OfflinePaymentMethodWithDescriptionCell.ROW_HEIGHT
                }
            }
            return PaymentSearchCell.ROW_HEIGHT
        }
        return PaymentTitleViewCell.ROW_HEIGHT
    }
    
    func getExcludedPaymentTypeIds() -> Set<String>? {
        return (self.paymentPreference != nil) ? self.paymentPreference!.excludedPaymentTypeIds : nil
    }
    
    func getExcludedPaymentMethodIds() -> Set<String>? {
        return (self.paymentPreference != nil) ? self.paymentPreference!.excludedPaymentMethodIds : nil
    }
    
    func setPaymentMethodSearch(_ paymentMethodSearchResponse : PaymentMethodSearch){
        self.paymentMethods = paymentMethodSearchResponse.paymentMethods
        self.currentPaymentMethodSearch = paymentMethodSearchResponse.groups
        
        if paymentMethodSearchResponse.customerPaymentMethods != nil && paymentMethodSearchResponse.customerPaymentMethods!.count > 0 {
            self.customerCards = paymentMethodSearchResponse.customerPaymentMethods! as [CardInformation]
        }

    }
    
    
    internal func optionSelected(_ paymentSearchItemSelected : PaymentMethodSearchItem, navigationController : UINavigationController, cancelPaymentCallback : @escaping ((Void) -> (Void)),animated: Bool = true) {
        
        switch paymentSearchItemSelected.type.rawValue {
        case PaymentMethodSearchItemType.PAYMENT_TYPE.rawValue:
            let paymentTypeId = PaymentTypeId(rawValue: paymentSearchItemSelected.idPaymentMethodSearchItem)
            
            if paymentTypeId!.isCard() {
                let cardFlow = MPFlowBuilder.startCardFlow(self.paymentPreference, amount: self.amount, paymentMethods : self.paymentMethods, callback: { (paymentMethod, token, issuer, payerCost) in
                    self.callback!(paymentMethod, token, issuer, payerCost)
                    }, callbackCancel: {
                        cancelPaymentCallback()
                })
                
                navigationController.pushViewController(cardFlow.viewControllers[0], animated: animated)
            } else {
                navigationController.pushViewController(MPStepBuilder.startPaymentMethodsStep(callback: {    (paymentMethod : PaymentMethod) -> Void in
                    self.callback!(paymentMethod, nil, nil, nil)
                }), animated: true)
            }
            break
        case PaymentMethodSearchItemType.PAYMENT_METHOD.rawValue:
            if paymentSearchItemSelected.idPaymentMethodSearchItem == PaymentTypeId.ACCOUNT_MONEY.rawValue {
                //MP wallet
            } else if paymentSearchItemSelected.idPaymentMethodSearchItem == PaymentTypeId.BITCOIN.rawValue {
                
            } else {
                // Offline Payment Method
                let offlinePaymentMethodSelected = Utils.findPaymentMethod(self.paymentMethods, paymentMethodId: paymentSearchItemSelected.idPaymentMethodSearchItem)
                self.callback!(offlinePaymentMethodSelected, nil, nil, nil)
            }
            break
        default:
            //TODO : HANDLE ERROR
            break
        }
    }

}
