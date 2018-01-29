//
//  Constant.swift
//  SurveyApp
//
//  Created by ridzuan othman on 13/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import Foundation
import UIKit
import SCLAlertView
import RealmSwift
import Alamofire
import SystemConfiguration

let realm = try! Realm()
let defaults = UserDefaults.standard

func hexStringToUIColor(hex: String) -> UIColor {
    var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.characters.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue: UInt32 = 0
    Scanner(string: cString).scanHexInt32(&rgbValue)
    
    return UIColor(
        red:CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green:CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue:CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha:CGFloat(1.0)
    )
}

func showErrorMessage(_ message: String) {
    let errorView = SCLAlertView()
    errorView.showError("Error!", subTitle:message, closeButtonTitle:"Close", colorStyle:0xFF0000)
}

func setUrlRequest(_ url: String) -> URLRequest{
    
    var request = URLRequest(url: URL(string: "\(settings.api.baseUrl)\(url)")!)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("FrsApi \(defaults.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
    
    return request
}

func nilIfEmpty(_ data: AnyObject) -> String{
    return data as? String == nil ? "-" : data as! String
}

func setToken(){
    Api.getToken().continueWith { (task) -> Any? in
        if task.succeed {}else{
            task.showError()
        }
        return nil
    }
}

//Check internet connection
func isConnectedToNetwork() -> Bool {
    
    var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
    zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
    zeroAddress.sin_family = sa_family_t(AF_INET)
    
    let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
            SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
        }
    }
    
    var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
    if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
        return false
    }
    
    // Working for Cellular and WIFI
    let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
    let ret = (isReachable && !needsConnection)
    
    return ret
    
}
