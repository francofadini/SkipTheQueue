//
//  LoadingOverlay.swift
//  MercadoPagoSDK
//
//  Created by Maria cristina rodriguez on 29/4/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

open class LoadingOverlay {
    
    var container = UIView()
    var screenContainer = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }

    init(){
        
    }
    
    open func getLoadingOverlay(_ view : UIView, backgroundColor : UIColor, indicatorColor : UIColor) -> UIView {
        
        
        
        self.activityIndicator.frame = CGRect(x: 30,y: 30, width: 20, height: 20)
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicator.color = indicatorColor
        self.activityIndicator.isHidden = false
        
        self.container.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        self.container.backgroundColor = UIColor.clear
        self.container.alpha = 1
        self.container.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2 )
        self.container.layer.cornerRadius = 10.0
        self.container.addSubview(self.activityIndicator)
        
        self.screenContainer.frame = CGRect(x : view.bounds.minX, y : view.bounds.minY, width : view.bounds.width, height : view.bounds.height)
        self.screenContainer.backgroundColor = backgroundColor.withAlphaComponent(0.8)
        self.screenContainer.addSubview(self.container)
        
        self.activityIndicator.startAnimating()
        return self.screenContainer
    }
    
    open func showOverlay(_ view: UIView, backgroundColor : UIColor, indicatorColor : UIColor) {
        let overlay = self.getLoadingOverlay(view, backgroundColor : backgroundColor, indicatorColor: indicatorColor)
        view.addSubview(overlay)
        view.bringSubview(toFront: overlay)
    }
    
    open func hideOverlayView() {
        activityIndicator.stopAnimating()
        screenContainer.removeFromSuperview()
    }
}
