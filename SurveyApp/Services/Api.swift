//
//  Api.swift
//  SurveyApp
//
//  Created by ridzuan othman on 18/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import Foundation
import BoltsSwift
import Alamofire
import Bolts
import RealmSwift

class Api{
    
    class func logout() {
        let user = User.current
        do {
            let realm = try Realm()
            try realm.write {
                user.isLogin = false
                realm.delete(User.current.survey)
                let viewController = UIApplication.shared.delegate as! AppDelegate
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let FirstNavigationVC = storyboard.instantiateViewController(withIdentifier: "LoginNav")
                viewController.window!.rootViewController = FirstNavigationVC
            }
        }
        catch _ {}
    }
    
    class func getToken() -> BFTask<AnyObject>{
        
        let future = BFTaskCompletionSource<AnyObject>()
        
        Alamofire.request("\(settings.api.baseUrl)token", method: .post).responseJSON { (response) in
            
            guard let data = response.result.value as? [String:AnyObject],
            let token = data["data"] as? [String:AnyObject] else{
                
                future.error(response.result.value as? [String:AnyObject])
                return
                
            }
            
            defaults.set(token["token"], forKey: "token")
            defaults.synchronize()
            
            future.set(result: nil)
        }
        
        return future.task
        
    }
    
    class func login(_ username: String, _ password: String) -> BFTask<AnyObject>{
        
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/authenticate")
        request.httpMethod = HTTPMethod.post.rawValue
        
        let json = "{\"icnumber\":\"\(username)\", \"password\":\"\(password)\"}"
        let jsonData = json.data(using: .utf8, allowLossyConversion: false)!
        
        request.httpBody = jsonData
        
        Alamofire.request(request).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if (data["error"] as? String) != nil{
                future.error(response.result.value as? [String:AnyObject])
            }else{
                future.set(result: nil)
            }
            
            
        }
        
        return future.task
    }
    
    class func getUserInfo(_ username: String) -> BFTask<AnyObject>{
        
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/user/\(username)")
        request.httpMethod = HTTPMethod.get.rawValue
        
        Alamofire.request(request).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if data["code"] as! Int == 200{
                try! realm.write {
                    
                    let info = data["data"] as! Dictionary<String, AnyObject>
                    let user = User.current
                    
                    user.isLogin = true
                    user.icnumber = nilIfEmpty(info["IcNumber"]!)
                    user.name = nilIfEmpty(info["Name"]!)
                    user.email = nilIfEmpty(info["Email"]!)
                    user.phoneno = nilIfEmpty(info["PhoneNo"]!)
                    user.rolename = nilIfEmpty(info["Role"]!)
                    
                    realm.delete(user.parlimen)
                    
                    if let parlimenInfo = info["Locations"] as? [Dictionary<String,AnyObject>]{
                        
                        for tempInfo in parlimenInfo{
                            let parlimen = Parlimen()
                            parlimen.stateId = nilIfEmpty(tempInfo["StateId"]!)
                            parlimen.state = nilIfEmpty(tempInfo["State"]!)
                            parlimen.parlimenCode = nilIfEmpty(tempInfo["ParlimenCode"]!)
                            parlimen.parlimen = nilIfEmpty(tempInfo["Parlimen"]!)
                            parlimen.dunCode = nilIfEmpty(tempInfo["DunCode"]!)
                            parlimen.dun = nilIfEmpty(tempInfo["Dun"]!)
                            parlimen.pdmCode = nilIfEmpty(tempInfo["PdmCode"]!)
                            parlimen.pdm = nilIfEmpty(tempInfo["Pdm"]!)
                            
                            user.parlimen.append(parlimen)
                        }
                        
                    }
    
                    future.set(result: nil)
                }
            }else{
                future.error(["error" : "Internal server error" as AnyObject])
            }
            
        }
        
        return future.task
    }
    
    class func getCategory() -> BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/categories")
        request.httpMethod = HTTPMethod.get.rawValue
        
        Alamofire.request(request).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if data["code"] as! Int == 200{
                
                let items = data["data"] as! Dictionary<String, AnyObject>
                let user = User.current.categories
                
                try! realm.write {
                    
                    realm.delete(user)
                    for itemsData in items["items"] as! [Dictionary<String,AnyObject>]{
                        
                        let category = Categories()
                        
                        category.categoryTitle = itemsData["title"] as! String
                        category.categoryId = itemsData["id"] as! String
                        
                        user.append(category)
                    }
                    
                }
                
            }else{
                future.error(response.result.value as? [String:AnyObject])
            }
            
            future.set(result: nil)
        }
        
        return future.task
    }
    
    class func generateId() -> BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/generate/id")
        request.httpMethod = HTTPMethod.get.rawValue
        
        Alamofire.request(request).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if let _ = data["status"] as? String{
                if data["message"] as! String == "Expired token"{
                    future.error(["error" : data["message"]!])
                }
            }else{
                
                try! realm.write {
                    
                    let user = User.current
                    user.id = ""
                    if let id = data["data"] as? Dictionary<String, AnyObject>{
                        user.id = id["id"] as! String
                    }
                    
                    future.set(result: nil)
                }
                
            }
        }
        
        return future.task
    }

    class func getChecklist() -> BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/checklist/submission/\(User.current.icnumber)")
        request.httpMethod = HTTPMethod.get.rawValue
        
        Alamofire.request(request).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if let _ = data["status"] as? String{
                if data["message"] as! String == "Expired token"{
                    future.error(["error" : data["message"]!])
                }
            }else{
                
                try! realm.write {
                    
                    let user = User.current
                    realm.delete(user.checklist)
                    
                    for checklistData in data["data"] as! [Dictionary<String, AnyObject>]{
                        
                        let checklist = Checklist()
                        
                        checklist.checklistid = checklistData["checklistid"] as! Int
                        checklist.checklist_text = checklistData["checklist_text"] as! String
                        checklist.progressStatus = checklistData["progressStatus"] as! String
                        checklist.comment = checklistData["comment"] as! String
                        
                        user.checklist.append(checklist)
                        
                    }
                    
                    future.set(result: nil)
                }
                
            }
        }
        
        return future.task
    }
    
    class func submitSurvey(_ status: String, _ surveyIndex: Int) -> BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        let headers = ["Authorization": "FrsApi \(defaults.string(forKey: "token")!)"]
        
        let survey = User.current
        let parlimen = survey.parlimen.filter("parlimenCode == %@", survey.parlimenId)
        
        var params = [String:String]()
        params["IcNumber"] = "\(survey.icnumber)"
        
        if parlimen.count != 0{
            params["locationCode"] = "\(parlimen[0].parlimenCode)"
            params["locationName"] = "\(parlimen[0].parlimen)"
            params["locationType"] = "\(parlimen[0].parlimenCode)"
        }
        
        params["content[]"] = "{\"categoryid\":\"\(survey.categoryId)\", \"issue\":\"\(survey.issue)\",\"wishlist\":\"\(survey.wishlist)\"}"
        
        if status == "edit"{
            let tempSurvey = survey.survey[surveyIndex]
            params["id"] = tempSurvey.id
        }
        
        Alamofire.request(URL(string: "\(settings.api.baseUrl)v1/surveys")!, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if let _ = data["status"] as? String{
                if data["message"] as! String == "Expired token"{
                    future.error(["error" : data["message"]!])
                }
            }else{
                
                try! realm.write {
                    
                    if status == "edit"{
                        
                        let survey = User.current.survey[surveyIndex]
                        let info = data["data"] as! Dictionary<String,AnyObject>
                        
                        if survey.id == info["id"] as! String{
                            
                        }else{
                            
                            realm.delete(survey)
                            
                            let survey = Survey()
                            let user = User.current
                            let info = data["data"] as! Dictionary<String,AnyObject>
                            
                            survey.id = info["id"] as! String
                            survey.status = "server"
                            survey.categoryId = user.categoryId
                            survey.categoryTitle = user.categoryTitle
                            survey.parlimenTitle = user.parlimenTitle
                            survey.parlimenId = user.parlimenId
                            survey.issue = user.issue
                            survey.wishlist = user.wishlist
                            survey.photo = user.photo
                            survey.video = user.video
                            survey.created = Date()
                            survey.updated = Date()
                            
                            user.survey.insert(survey, at: surveyIndex)
                            
                        }
                        
                    }else{
                        
                        let survey = Survey()
                        let user = User.current
                        let info = data["data"] as! Dictionary<String,AnyObject>
                        
                        survey.id = info["id"] as! String
                        survey.status = "server"
                        survey.categoryId = user.categoryId
                        survey.categoryTitle = user.categoryTitle
                        survey.parlimenTitle = user.parlimenTitle
                        survey.parlimenId = user.parlimenId
                        survey.issue = user.issue
                        survey.wishlist = user.wishlist
                        survey.photo = user.photo
                        survey.video = user.video
                        survey.created = Date()
                        survey.updated = Date()
                        
                        user.survey.append(survey)
                        
                    }
                    
                    future.set(result: nil)
                    
                }
                
            }
        }
        
        return future.task
    }
}
