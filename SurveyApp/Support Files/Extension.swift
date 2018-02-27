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
        
    }
}

