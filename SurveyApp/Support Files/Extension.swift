//
//  Extension.swift
//  SurveyApp
//
//  Created by ridzuan othman on 18/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import Foundation
import Bolts
import RealmSwift

extension BFTask{
    @objc func showError(){
        if let msg = (error as NSError?)?.domain, msg != "" {
            showErrorMessage(msg)
        }
    }
    
    @objc var succeed:Bool{
        return self.error == nil
    }
}

extension BFTaskCompletionSource {
    @objc func error(_ data:[String:AnyObject]?=nil) {
        
        if !isConnectedToNetwork(){
            set(error: NSError(domain: "You have no internet connection.", code: 0, userInfo: nil))
        }else{
            if let error = data?["error"]{
                set(error: NSError(domain: error as! String, code: 0, userInfo: nil))
            }
        }
        
        
        /*if let error = data?["errors"]{
            if error.classForCoder == NSArray.classForCoder(){
                let errors = error  as! [Dictionary<String,AnyObject>]
                set(error: NSError(domain: errors[0]["message"] as! String, code: 0, userInfo: nil))
            }else{
                let errors = error  as! Dictionary<String,AnyObject>
                set(error: NSError(domain: errors["detail"] as! String, code: 0, userInfo: nil))
            }
            
        }else if let err = data?["error"]{
            set(error: NSError(domain: err as! String, code: 0, userInfo: nil))
        }else{
            
            if isConnectedToNetwork(){
                set(error: NSError(domain: "error_common".localized, code: 0, userInfo: nil))
            }else{
                set(error: NSError(domain: "error_internet_connection".localized, code: 0, userInfo: nil))
            }
        }*/
    }
}

