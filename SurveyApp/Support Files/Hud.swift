//
//  Hud.swift
//  whereabout
//
//  Created by Стас on 12/08/15.
//  Copyright (c) 2015 Limehat. All rights reserved.
//

import UIKit
import CRToast
import MMMaterialDesignSpinner

class Hud: UIView {

    static var spinner1 = MMMaterialDesignSpinner()

    static func addHud(_ view: UIView){
        spinner1 = MMMaterialDesignSpinner(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        spinner1.lineWidth = 5
        spinner1.tintColor = UIColor.fromHex(0xBB2034)
        view.addSubview(spinner1)

        spinner1.startAnimating()
    }

    static func stopHud(_ view: UIView, status: String){

        let imgView:UIImageView = UIImageView.init(image: UIImage(named: "\(status)Img"))
        imgView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        view.addSubview(imgView)
        
        spinner1.stopAnimating()
    }

    static func show(_ view: UIView, backgroundColor:UIColor=UIColor.clear) {
        Hud.show(view, width: 50, lineWidth: 5, color: UIColor.fromHex(0xEB4B5F), backgroundColor: backgroundColor)
    }
    
    static func show(_ view: UIView, width:CGFloat, lineWidth:CGFloat, color:UIColor, backgroundColor:UIColor=UIColor.clear) {
        sharedInstance?.hide()
        sharedInstance = Hud(view: view, width: width, lineWidth: lineWidth, color: color, backgroundColor: backgroundColor)
        sharedInstance?.show()
    }
    
    static func hide() {
        sharedInstance?.hide()
    }
    
    static func success(_ message:String) {
        Hud.hide()
        Hud.message(message, color: UIColor.fromHex(0x98DB23))
    }
    
    static func info(_ message:String) {
        Hud.hide()
        Hud.message(message, color: UIColor.fromHex(0x008BEE))
    }
    
    static func error(_ message:String) {
        Hud.hide()
        Hud.message(message, color: UIColor.fromHex(0xEA0000))
    }
    
    static func message(_ message:String, color:UIColor) {
        Hud.hide()
        CRToastManager.showNotification(options: [
            kCRToastTextKey: message,
            kCRToastBackgroundColorKey: color,
            kCRToastTextColorKey: UIColor.white,
            kCRToastNotificationTypeKey: CRToastType.navigationBar.rawValue,
            kCRToastNotificationPresentationTypeKey: CRToastPresentationType.cover.rawValue,
            kCRToastAnimationInDirectionKey: CRToastAnimationDirection.top.rawValue,
            kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.top.rawValue,
            kCRToastAnimationInTypeKey: CRToastAnimationType.gravity.rawValue,
            kCRToastAnimationOutTypeKey: CRToastAnimationType.gravity.rawValue], completionBlock: nil)
    }
    
    init(view: UIView, width:CGFloat, lineWidth:CGFloat, color:UIColor, backgroundColor:UIColor=UIColor.clear) {
        super.init(frame: view.frame)
        self.backgroundColor = backgroundColor
        spinner = MMMaterialDesignSpinner(frame:CGRect(x: view.frame.width/2 - width/2, y: view.frame.height/2 - width/2, width: width, height: width))
        spinner.lineWidth = lineWidth
        spinner.tintColor = color
        addSubview(spinner)
        view.addSubview(self)
    }
    
    func show() {
        spinner.startAnimating()
    }
    
    func hide() {
        spinner.stopAnimating()
        removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var spinner:MMMaterialDesignSpinner!
    static var sharedInstance:Hud?
}
