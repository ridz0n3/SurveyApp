//
//  Survey06ViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 14/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import Alamofire

class Survey06ViewController: BaseViewController {
    
    @IBOutlet weak var parlimenTitleLbl: UILabel!
    @IBOutlet weak var parlimenDescLbl: UILabel!
    @IBOutlet weak var categoryDescLbl: UILabel!
    @IBOutlet weak var issueDescLbl: UILabel!
    @IBOutlet weak var wishlistDescLbl: UILabel!
    @IBOutlet weak var wishlistView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("second", title: "Survey Review")
        processNumber(6)
        
        if status == "add"{
            
            let user = User.current
            
            if user.rolename == "PDMLeader"{
                parlimenTitleLbl.text = "PDM"
                parlimenDescLbl.text = user.parlimen[0].pdm.capitalized
            }else{
                parlimenDescLbl.text = user.parlimenTitle.capitalized
            }
            
            categoryDescLbl.text = user.categoryTitle
            issueDescLbl.text = user.issue
            
            if user.wishlist == ""{
                wishlistView.isHidden = true
            }else{
                wishlistDescLbl.text = user.wishlist
            }
            
            if isConnectedToNetwork(){
                Hud.show(view)
                Api.generateId().continueWith(block: { (task) -> Any? in
                    Hud.hide()
                    if task.succeed{}else{
                        task.showError()
                    }
                    return nil
                })
            }else{
                
                try! realm.write {
                    let user = User.current
                    user.id = NSUUID().uuidString.lowercased()
                }
                
            }
        }else{
            
            let user = User.current
            if user.rolename == "PDMLeader"{
                let parlimenArr = user.parlimen.filter("pdmCode == %@", survey.parlimenId)
                
                if parlimenArr.count > 0{
                    parlimenTitleLbl.text = "PDM"
                    parlimenDescLbl.text = parlimenArr.last?.pdm.capitalized
                }
            }else{
                parlimenDescLbl.text = survey.parlimenTitle.capitalized
            }
            
            categoryDescLbl.text = survey.categoryTitle
            issueDescLbl.text = survey.issue
            
            if survey.wishlist == ""{
                wishlistView.isHidden = true
            }else{
                wishlistDescLbl.text = survey.wishlist
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func submitPhoto(_ id: String){
        
        let survey = User.current.survey.filter("id == %@", id)
        
        if survey.count != 0{
            
                
                var photo = [Data]()
                
                for imgData in (survey.last?.photo)!{
                    photo.append(imgData.imgData)
                }
                
                var request = try! URLRequest(url: URL(string: "\(settings.api.baseUrl)v1/surveys/photos")!, method: .post)
                
                request.setValue("FrsApi \(defaults.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
                request.setValue("multipart/form-data", forHTTPHeaderField: "ContentType")
                
                Alamofire.upload(multipartFormData: { multipartFormData in
                    // code
                    
                    multipartFormData.append("\(User.current.icnumber)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "icnumber")
                    
                    multipartFormData.append("\(id)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "id")
                   
                    let survey = User.current
                    if survey.rolename == "PDMLeader"{
                        let parlimenArr = survey.parlimen.filter("pdmCode == %@", survey.parlimenId)
                        
                        if parlimenArr.count != 0{
                            multipartFormData.append("\(parlimenArr[0].pdmCode)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationCode")
                            multipartFormData.append("\(parlimenArr[0].pdm)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationName")
                            multipartFormData.append("PDM".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationType")
                        }else{
                            let parlimen = survey.parlimen.filter("parlimenCode == %@", survey.parlimenId)
                            
                            if parlimen.count != 0{
                                multipartFormData.append("\(parlimen[0].pdmCode)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationCode")
                                multipartFormData.append("\(parlimen[0].pdm)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationName")
                                multipartFormData.append("PDM".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationType")
                            }
                        }
                    }else{
                        let parlimenArr = survey.parlimen.filter("parlimenCode == %@", survey.parlimenId)
                        
                        if parlimenArr.count != 0{
                            multipartFormData.append("\(parlimenArr[0].parlimenCode)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationCode")
                            multipartFormData.append("\(parlimenArr[0].parlimen)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationName")
                            multipartFormData.append("PAR".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationType")
                        }
                    }
                    
                    var i = 0
                    for img in photo{
                        let imageData:Data = img
                        multipartFormData.append(imageData, withName: "photos[]", fileName: "\(i).png", mimeType: "image/png")
                        i += 1
                    }
                    
                }, with: request, encodingCompletion: { (result) in
                    // code
                    switch result {
                    case .success(let upload, _ , _):
                        
                        upload.uploadProgress(closure: { (progress) in
                        })
                        
                        upload.responseJSON(completionHandler: { (response) in
                            
                            guard let data = response.result.value as? [String: AnyObject] else{
                                showErrorMessage("Internal server error")
                                return
                            }
                            
                            if data["code"] as! Int == 201{
                                let user = User.current
                                
                                if user.updateVideo{
                                    self.submitVideo(id)
                                }else{
                                    Hud.hide()
                                    showToastMessage("Survey successfuly updated!")
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                                    self.navigationController?.popToRootViewController(animated: true)
                                }
                            }else{
                                Hud.hide()
                                showErrorMessage(data["message"] as! String)
                            }
                        })
                        
                    case .failure(let _):
                        Hud.hide()
                        print("failed")
                        showErrorMessage("Internal server error")
                        
                    }
                })
                
            }else{
                submitVideo(id)
            }
        
    }
    
    @objc func submitVideo(_ id: String){
        
        let survey = User.current.survey.filter("id == %@", id)
        
        if survey.count != 0{
            
                var uploadedUrlArr = [URL]()
                
                for videoUrl in (survey.last?.video)!{
                    
                    if URL(string: videoUrl.url)!.host != "dghill-datalake.s3.ap-southeast-1.amazonaws.com"{
                        uploadedUrlArr.append(URL(string: videoUrl.url)!)
                    }
                    
                }
            
            var request = try! URLRequest(url: URL(string: "\(settings.api.baseUrl)v1/surveys/videos")!, method: .post)
            request.setValue("FrsApi \(defaults.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
            
            Alamofire.upload(multipartFormData: { multipartFormData in
                // code
                var i = 0
                for url in uploadedUrlArr{
                    multipartFormData.append(url, withName: "videos[\(i)]", fileName: "vdeo.mp4", mimeType: "video/mp4")
                    i += 1
                }
                
                multipartFormData.append("\(User.current.icnumber)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "icnumber")
                
                multipartFormData.append("\(id)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "id")
                let survey = User.current
                if survey.rolename == "PDMLeader"{
                    let parlimenArr = survey.parlimen.filter("pdmCode == %@", survey.parlimenId)
                    
                    if parlimenArr.count != 0{
                        multipartFormData.append("\(parlimenArr[0].pdmCode)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationCode")
                        multipartFormData.append("\(parlimenArr[0].pdm)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationName")
                        multipartFormData.append("PDM".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationType")
                    }else{
                        let parlimen = survey.parlimen.filter("parlimenCode == %@", survey.parlimenId)
                        
                        if parlimen.count != 0{
                            multipartFormData.append("\(parlimen[0].pdmCode)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationCode")
                            multipartFormData.append("\(parlimen[0].pdm)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationName")
                            multipartFormData.append("PDM".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationType")
                        }
                    }
                }else{
                    let parlimenArr = survey.parlimen.filter("parlimenCode == %@", survey.parlimenId)
                    
                    if parlimenArr.count != 0{
                        multipartFormData.append("\(parlimenArr[0].parlimenCode)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationCode")
                        multipartFormData.append("\(parlimenArr[0].parlimen)".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationName")
                        multipartFormData.append("PAR".data(using: String.Encoding.utf8, allowLossyConversion: true)!, withName: "locationType")
                    }
                }
                
            }, with: request, encodingCompletion: { (result) in
                // code
                switch result {
                case .success(let upload, _ , _):
                    
                    upload.uploadProgress(closure: { (progress) in
                    })
                    
                    upload.responseJSON(completionHandler: { (response) in
                        Hud.hide()
                        
                        guard let data = response.result.value as? [String: AnyObject] else{
                            showErrorMessage("Internal server error")
                            return
                        }
                        
                        if data["code"] as! Int == 201{
                            showToastMessage("Survey successfuly updated!")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                            self.navigationController?.popToRootViewController(animated: true)
                        }else{
                            showErrorMessage(data["message"] as! String)
                        }
                    })
                    
                case .failure(let _):
                    Hud.hide()
                    print("failed")
                    showErrorMessage("Internal server error")
                    
                }
            })
            }else{
                Hud.hide()
                showToastMessage("Survey successfuly created!")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
    }
    
    @objc func submitSurvey(){
        let user = User.current
        
        try! realm.write {
            if status == "edit"{
                
                let survey = user.survey.sorted(byKeyPath: "updated", ascending: false)[surveyIndex]
                
                survey.status = "local"
                survey.categoryId = user.categoryId
                survey.categoryTitle = user.categoryTitle
                survey.parlimenTitle = user.parlimenTitle
                survey.parlimenId = user.parlimenId
                survey.issue = user.issue
                survey.wishlist = user.wishlist
                survey.updated = Date()
                survey.updateImg = user.updateImg
                survey.updateVideo = user.updateVideo
                
                if user.updateImg{
                    realm.delete(survey.photo)
                    for data in user.photo{
                        let photo = Photo()
                        
                        photo.imgData = data.imgData
                        photo.imgUrl = data.imgUrl
                        
                        survey.photo.append(photo)
                    }
                }
                
                if user.updateVideo{
                    realm.delete(survey.video)
                    for data in user.video{
                        let video = VideoSurvey()
                        
                        video.thumbnail = data.thumbnail
                        video.url = data.url
                        
                        survey.video.append(video)
                    }
                }
                survey.updated = Date()
                
                realm.create(Survey.self, value: survey, update: true)
                showToastMessage("Survey successfuly updated!")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
                
            }else{
                
                let survey = Survey()
                
                survey.id = user.id
                survey.status = "local"
                survey.categoryId = user.categoryId
                survey.categoryTitle = user.categoryTitle
                survey.parlimenTitle = user.parlimenTitle
                survey.parlimenId = user.parlimenId
                survey.issue = user.issue
                survey.wishlist = user.wishlist
                survey.updateImg = false
                survey.updateVideo = false
                
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
                
                let formater = DateFormatter()
                formater.dateFormat = "yyyy-MM-dd"
                survey.createdString = (formater.string(from: Date())).components(separatedBy: " ")[0]
                survey.created = Date()
                survey.updated = Date()
                
                user.survey.append(survey)
                showToastMessage("Survey successfuly created!")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        
        if isConnectedToNetwork(){
            Hud.show(view)
            Api.submitSurvey(status, surveyIndex).continueWith(block: { (task) -> Any? in
                
                if task.succeed{
                    
                    if self.status == "edit"{
                        let user = User.current
                        if user.updateImg{
                            self.submitPhoto(task.result as! String)
                        }else if user.updateVideo{
                            self.submitVideo(task.result as! String)
                        }else{
                            Hud.hide()
                            showToastMessage("Survey successfuly updated!")
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else{
                        self.submitPhoto(task.result as! String)
                    }
                    
                }else{
                    Hud.hide()
                    task.showError()
                }
                return nil
            })
        }else{
            submitSurvey()
        }
        
    }
    
    @IBAction func surveyListingBtnPressed(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        submitSurvey()
    }
}
