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
                realm.delete(User.current.checklist)
                
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
                
                let token = data["data"] as! [String:AnyObject]
                
                defaults.set(token["token"], forKey: "tokenLog")
                defaults.synchronize()
                
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
                future.error(["error" : data["message"]!])
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
            }else if data["code"] as! Int == 201{
                
                try! realm.write {
                    
                    let user = User.current
                    user.id = ""
                    if let id = data["data"] as? Dictionary<String, AnyObject>{
                        user.id = id["id"] as! String
                    }
                    
                    future.set(result: nil)
                }
                
            }else{
                future.error(["error" : data["message"] as AnyObject])
            }
        }
        
        return future.task
    }
    
    class func getChecklist() -> BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/checklist")
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
            }else if data["code"] as! Int == 200{
                
                try! realm.write {
                    
                    var parent = [Dictionary<String, AnyObject>]()
                    var child = [Dictionary<String, AnyObject>]()
                    
                    for checklistData in data["data"] as! [Dictionary<String, AnyObject>]{
                        
                        let hasChild = checklistData["has_child"] as! Bool
                        let parentId = checklistData["parent_id"] as! String
                        
                        if hasChild || parentId == "0"{
                            parent.append(checklistData)
                        }else{
                            child.append(checklistData)
                        }
                        
                    }
                    
                    let user = User.current
                    
                    for tempData in parent{
                        
                        let check = user.checklist.filter("itemid == %@", tempData["id"] as! String)
                        
                        if check.count == 0{
                            let checklist = Checklist()
                            checklist.checklistid = NSUUID().uuidString.lowercased()
                            checklist.itemid = tempData["id"] as! String
                            checklist.checklist_text = tempData["text"] as! String
                            
                            if tempData["has_child"] as! Bool{
                                
                                for tempChild in child{
                                    
                                    if tempChild["parent_id"] as! String == tempData["id"] as! String{
                                        let checklistChild = ChecklistChild()
                                        checklistChild.checklistid = NSUUID().uuidString.lowercased()
                                        checklistChild.itemid = tempChild["id"] as! String
                                        checklistChild.checklist_text = tempChild["text"] as! String
                                        
                                        checklist.child.append(checklistChild)
                                    }
                                    
                                }
                                
                            }
                            user.checklist.append(checklist)
                        }
                        
                    }
                    
                    future.set(result: nil)
                }
                
            }else{
                future.error(["error" : data["message"]!])
            }
        }
        
        return future.task
    }
    
    class func getChecklistSubmission() -> BFTask<AnyObject>{
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
            }else if data["code"] as! Int == 200{
                
                try! realm.write {
                    
                    let user = User.current
                    if let checkData = data["data"] as? Dictionary<String, AnyObject>{
                        
                        user.checkListId = checkData["id"] as! String
                        
                        for checklistData in checkData["content"] as! [Dictionary<String, AnyObject>]{
                            
                            for checklist in user.checklist{
                                
                                let check = checklist.child.filter("itemid == %@", checklistData["itemid"] as! String)
                                
                                if check.count != 0{
                                    
                                    let index = checklist.child.index(of: check.last!)!
                                    let tempChecklist = checklist.child[index]
                                    
                                    tempChecklist.itemid = checklistData["itemid"] as! String
                                    tempChecklist.progressStatus = checklistData["check"] as! String
                                    tempChecklist.comment = checklistData["comment"] as! String
                                    tempChecklist.location = "server"
                                    tempChecklist.isExisting = true
                                    
                                    realm.create(ChecklistChild.self, value: tempChecklist, update: true)
                                    
                                }
                            }
                        }
                        
                        future.set(result: nil)
                    }else{
                        future.set(result: nil)
                    }
                }
                
            }else{
                future.error(["error" : data["message"]!])
            }
        }
        
        return future.task
    }
    
    class func postChecklist(_ content: [String]) ->BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        let headers = ["Authorization": "FrsApi \(defaults.string(forKey: "token")!)"]
        
        let checklist = User.current
        let parlimen = checklist.parlimen
        
        var params = [String:String]()
        params["IcNumber"] = "\(checklist.icnumber)"
        params["locationCode"] = "\(parlimen[0].pdmCode)"
        params["locationName"] = "\(parlimen[0].pdm)"
        params["locationType"] = "PDM"
        
        if checklist.checkListId != ""{
            params["id"] = checklist.checkListId
        }
        
        var count = 0
        for data in content{
            params["content[\(count)]"] = data
            count += 1
        }
        
        Alamofire.request(URL(string: "\(settings.api.baseUrl)v1/checklist")!, method: .post, parameters: params, headers: headers).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if let _ = data["status"] as? String{
                if data["message"] as! String == "Expired token"{
                    future.error(["error" : data["message"]!])
                }
            }else if data["code"] as! Int == 201{
                
                try! realm.write {
                    
                    if let checklist = data["data"] as? Dictionary<String, AnyObject>{
                        let id = checklist["id"] as! String
                        let user = User.current
                        user.checkListId = id
                    }
                    
                }
                future.set(result: nil)
            }else{
                future.error(response.result.value as? [String:AnyObject])
            }
        }
        
        return future.task
    }
    
    class func getSurveyList() -> BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/surveys/\(User.current.icnumber)")
        request.httpMethod = HTTPMethod.get.rawValue
        
        Alamofire.request(request).responseJSON { (response) in
            guard let data = response.result.value as? [String:AnyObject] else{
                future.error(response.result.value as? [String:AnyObject])
                return
            }
            
            if let _ = data["status"] as? String{
                if data["message"] as! String == "Expired token"{
                    future.error(["error" : data["message"]!])
                    return
                }
            }else if data["code"] as! Int == 200{
                
                try! realm.write {
                    
                    let surveyArr = data["data"] as! [Dictionary<String,AnyObject>]
                    
                    if surveyArr.count != 0{
                        
                        for surveyInfo in surveyArr{
                            
                            let user = User.current
                            let tempSurvey = user.survey.filter("id == %@", surveyInfo["id"] as! String)
                            
                            if tempSurvey.count == 0{
                                
                                let survey = Survey()
                                
                                survey.id = surveyInfo["id"] as! String
                                survey.status = "server"
                                survey.updateImg = false
                                survey.updateVideo = false
                                survey.processStatus = surveyInfo["processed"] as! Bool
                                survey.parlimenId = surveyInfo["locationCode"] as! String
                                
                                if user.rolename == "PDMLeader"{
                                    let parlimenArr = user.parlimen.filter("pdmCode == %@", surveyInfo["locationCode"] as! String)
                                    
                                    if parlimenArr.count != 0{
                                        survey.parlimenTitle = (parlimenArr.last?.parlimen)!
                                    }else{
                                        let parlimenArr2 = user.parlimen.filter("parlimenCode == %@", surveyInfo["locationCode"] as! String)
                                        
                                        if parlimenArr2.count != 0{
                                            survey.parlimenTitle = (parlimenArr2.last?.parlimen)!
                                        }
                                    }
                                }else{
                                    let parlimenArr = user.parlimen.filter("parlimenCode == %@", surveyInfo["locationCode"] as! String)
                                    
                                    if parlimenArr.count != 0{
                                        survey.parlimenTitle = (parlimenArr.last?.parlimen)!
                                    }
                                }
                                
                                
                                if let content = surveyInfo["content"] as? [Dictionary<String,AnyObject>]{
                                    
                                    if content.count != 0{
                                        survey.categoryId = content.first!["categoryid"] as! String
                                        
                                        let categoryArr = user.categories.filter("categoryId == %@", content.first!["categoryid"] as! String)
                                        
                                        if categoryArr.count != 0{
                                            survey.categoryTitle = (categoryArr.last?.categoryTitle)!
                                        }
                                        survey.issue = content.first!["issue"] as! String
                                        survey.wishlist = content.first!["wishlist"] as! String
                                    }
                                }
                                
                                let formater = dateFormater()
                                formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                
                                survey.createdString = (surveyInfo["created_at"] as! String).components(separatedBy: " ")[0]
                                survey.created = formater.date(from: surveyInfo["created_at"] as! String)!
                                survey.updated = formater.date(from: surveyInfo["updated_at"] as! String)!
                                
                                user.survey.append(survey)
                                
                            }else{
                                
                                let survey = tempSurvey.last!
                                
                                if survey.status == "server"{
                                    survey.status = "server"
                                    survey.processStatus = surveyInfo["processed"] as! Bool
                                    survey.parlimenId = surveyInfo["locationCode"] as! String
                                    survey.updateImg = false
                                    survey.updateVideo = false
                                    
                                    if user.rolename == "PDMLeader"{
                                        let parlimenArr = user.parlimen.filter("pdmCode == %@", surveyInfo["locationCode"] as! String)
                                        
                                        if parlimenArr.count != 0{
                                            survey.parlimenTitle = (parlimenArr.last?.parlimen)!
                                        }else{
                                            let parlimenArr2 = user.parlimen.filter("parlimenCode == %@", surveyInfo["locationCode"] as! String)
                                            
                                            if parlimenArr2.count != 0{
                                                survey.parlimenTitle = (parlimenArr2.last?.parlimen)!
                                            }
                                        }
                                    }else{
                                        let parlimenArr = user.parlimen.filter("parlimenCode == %@", surveyInfo["locationCode"] as! String)
                                        
                                        if parlimenArr.count != 0{
                                            survey.parlimenTitle = (parlimenArr.last?.parlimen)!
                                        }
                                    }
                                    
                                    if let content = surveyInfo["content"] as? [Dictionary<String,AnyObject>]{
                                        
                                        if content.count != 0{
                                            survey.categoryId = content.first!["categoryid"] as! String
                                            
                                            let categoryArr = user.categories.filter("categoryId == %@", content.first!["categoryid"] as! String)
                                            
                                            if categoryArr.count != 0{
                                                survey.categoryTitle = (categoryArr.last?.categoryTitle)!
                                            }
                                            survey.issue = content.first!["issue"] as! String
                                            survey.wishlist = content.first!["wishlist"] as! String
                                        }
                                    }
                                    
                                    let formater = dateFormater()
                                    formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    
                                    survey.updated = formater.date(from: surveyInfo["updated_at"] as! String)!
                                    
                                    realm.create(Survey.self, value: survey, update: true)
                                }
                            }
                            
                        }
                        
                    }
                    
                    future.set(result: nil)
                }
                
            }else{
                future.error(["error" : data["message"] as AnyObject])
            }
        }
        return future.task
    }
    
    class func submitSurvey(_ status: String, _ surveyIndex: Int) -> BFTask<AnyObject>{
        let future = BFTaskCompletionSource<AnyObject>()
        
        let headers = ["Authorization": "FrsApi \(defaults.string(forKey: "token")!)"]
        
        let survey = User.current
        
        var params = [String:String]()
        params["IcNumber"] = "\(survey.icnumber)"
        
        if survey.rolename == "PDMLeader"{
            let parlimenArr = survey.parlimen.filter("pdmCode == %@", survey.parlimenId)
            
            if parlimenArr.count != 0{
                params["locationCode"] = "\(parlimenArr[0].pdmCode)"
                params["locationName"] = "\(parlimenArr[0].pdm)"
                params["locationType"] = "PDM"
            }else{
                let parlimen = survey.parlimen.filter("parlimenCode == %@", survey.parlimenId)
                
                if parlimen.count != 0{
                    params["locationCode"] = "\(parlimen[0].pdmCode)"
                    params["locationName"] = "\(parlimen[0].pdm)"
                    params["locationType"] = "PDM"
                }
            }
        }else{
            let parlimenArr = survey.parlimen.filter("parlimenCode == %@", survey.parlimenId)
            
            if parlimenArr.count != 0{
                params["locationCode"] = "\(parlimenArr[0].parlimenCode)"
                params["locationName"] = "\(parlimenArr[0].parlimen)"
                params["locationType"] = "PAR"
            }
        }
        
        params["content[]"] = "{\"categoryName\":\"\(survey.categoryTitle)\", \"categoryid\":\"\(survey.categoryId)\", \"issue\":\"\(survey.issue)\",\"wishlist\":\"\(survey.wishlist)\"}"
        
        if status == "edit"{
            let tempSurvey = survey.survey.sorted(byKeyPath: "updated", ascending: false)[surveyIndex]
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
            }else if data["code"] as! Int == 201{
                
                try! realm.write {
                    
                    if status == "edit"{
                        
                        let tempSurvey = User.current.survey.sorted(byKeyPath: "updated", ascending: false)[surveyIndex]
                        let info = data["data"] as! Dictionary<String,AnyObject>
                        
                        let user = User.current
                        
                        if tempSurvey.status == "local"{
                            
                            if user.photo.count != 0{
                                realm.delete(tempSurvey.photo)
                                for data in user.photo{
                                    let photo = Photo()
                                    
                                    photo.imgData = data.imgData
                                    photo.imgUrl = data.imgUrl
                                    
                                    tempSurvey.photo.append(photo)
                                }
                            }
                            
                            if user.video.count != 0{
                                realm.delete(tempSurvey.video)
                                for data in user.video{
                                    let video = VideoSurvey()
                                    
                                    video.thumbnail = data.thumbnail
                                    video.url = data.url
                                    
                                    tempSurvey.video.append(video)
                                }
                            }
                            
                            user.updateImg = true
                            user.updateVideo = true
                        }else{
                            if user.updateImg{
                                realm.delete(tempSurvey.photo)
                                for data in user.photo{
                                    let photo = Photo()
                                    
                                    photo.imgData = data.imgData
                                    photo.imgUrl = data.imgUrl
                                    
                                    tempSurvey.photo.append(photo)
                                }
                                user.updateImg = true
                            }
                            
                            if user.updateVideo{
                                realm.delete(tempSurvey.video)
                                for data in user.video{
                                    let video = VideoSurvey()
                                    
                                    video.thumbnail = data.thumbnail
                                    video.url = data.url
                                    
                                    tempSurvey.video.append(video)
                                }
                                user.updateVideo = true
                            }
                        }
                        
                        tempSurvey.updateVideo = false
                        tempSurvey.updateImg = false
                        tempSurvey.status = "server"
                        tempSurvey.categoryId = user.categoryId
                        tempSurvey.categoryTitle = user.categoryTitle
                        tempSurvey.parlimenTitle = user.parlimenTitle
                        tempSurvey.parlimenId = user.parlimenId
                        tempSurvey.issue = user.issue
                        tempSurvey.wishlist = user.wishlist
                        tempSurvey.updated = Date()
                        
                        realm.create(Survey.self, value: tempSurvey, update: true)
                        future.set(result: info["id"] as AnyObject)
                        
                    }else{
                        
                        let survey = Survey()
                        let user = User.current
                        let info = data["data"] as! Dictionary<String,AnyObject>
                        
                        survey.id = info["id"] as! String
                        survey.status = "server"
                        survey.updateImg = false
                        survey.updateVideo = false
                        survey.categoryId = user.categoryId
                        survey.categoryTitle = user.categoryTitle
                        survey.parlimenTitle = user.parlimenTitle
                        survey.parlimenId = user.parlimenId
                        survey.issue = user.issue
                        survey.wishlist = user.wishlist
                        survey.created = Date()
                        survey.updated = Date()
                        
                        realm.delete(survey.photo)
                        realm.delete(survey.video)
                        
                        for data in user.photo{
                            let photo = Photo()
                            
                            photo.imgData = data.imgData
                            photo.imgUrl = data.imgUrl
                            
                            survey.photo.append(photo)
                        }
                        
                        for data in user.video{
                            let video = VideoSurvey()
                            
                            video.thumbnail = data.thumbnail
                            video.url = data.url
                            
                            survey.video.append(video)
                        }
                        
                        user.survey.append(survey)
                        future.set(result: info["id"] as AnyObject)
                        
                    }
                    
                }
                
            }else{
                future.error(["error" : data["message"]!])
            }
        }
        
        return future.task
    }
    
    class func getPhoto(_ id: String) -> BFTask<AnyObject>{
        
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/surveys/photos/\(id)")
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
            }else if data["code"] as! Int == 200{
                
                try! realm.write {
                    
                    if let photoData = data["data"] as? Dictionary<String,AnyObject>{
                        
                        let survey = User.current.survey.filter("id == %@", id)
                        
                        if survey.count != 0{
                            
                            if let content = photoData["content"] as? Dictionary<String, AnyObject>{
                                
                                realm.delete((survey.last?.photo)!)
                                
                                for imgUrl in content["images"] as! [String]{
                                    let photo = Photo()
                                    
                                    photo.imgUrl = imgUrl
                                    
                                    survey.last?.photo.append(photo)
                                }
                            }
                            
                        }
                    }
                    
                    future.set(result: nil)
                }
                
            }else{
                future.error(["error" : data["message"]!])
            }
        }
        
        return future.task
    }
    
    class func getVideo(_ id: String) -> BFTask<AnyObject>{
        
        let future = BFTaskCompletionSource<AnyObject>()
        
        var request = setUrlRequest("v1/surveys/videos/\(id)")
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
            }else if data["code"] as! Int == 200{
                
                try! realm.write {
                    
                    if let videoData = data["data"] as? Dictionary<String,AnyObject>{
                        
                        let survey = User.current.survey.filter("id == %@", id)
                        
                        if survey.count != 0{
                            
                            if let content = videoData["content"] as? Dictionary<String, AnyObject>{
                            
                                realm.delete((survey.last?.video)!)
                                
                                for videoUrl in content["videos"] as! [String]{
                                    let video = VideoSurvey()
                                    
                                    video.url = videoUrl
                                    
                                    survey.last?.video.append(video)
                                }
                            }
                        }
                    }
                    
                    future.set(result: nil)
                }
                
            }else{
                future.error(["error" : data["message"]!])
            }
        }
        
        return future.task
    }
}
