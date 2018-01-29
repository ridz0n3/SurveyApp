//
//  Survey06ViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 14/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class Survey06ViewController: BaseViewController {
    
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
            parlimenDescLbl.text = user.parlimenTitle
            categoryDescLbl.text = user.categoryTitle
            issueDescLbl.text = user.issue
            
            if user.wishlist == ""{
                wishlistView.isHidden = true
            }else{
                wishlistDescLbl.text = user.wishlist
            }
            
            Hud.show(view)
            Api.generateId().continueOnSuccessWith { (task) -> Any? in
                Hud.hide()
                if task.succeed{}else{
                    task.showError()
                }
                return nil
            }
        }else{
            let user = User.current.survey[surveyIndex]
            parlimenDescLbl.text = user.parlimenTitle
            categoryDescLbl.text = user.categoryTitle
            issueDescLbl.text = user.issue
            
            if user.wishlist == ""{
                wishlistView.isHidden = true
            }else{
                wishlistDescLbl.text = user.wishlist
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        
        Hud.show(view)
        Api.submitSurvey(status, surveyIndex).continueOnSuccessWith { (task) -> Any? in
            Hud.hide()
            if task.succeed{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                task.showError()
            }
            return nil
        }
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        let user = User.current
        
        try! realm.write {
            if status == "edit"{
                
                let survey = user.survey[surveyIndex]
                
                survey.status = "local"
                survey.categoryId = user.categoryId
                survey.categoryTitle = user.categoryTitle
                survey.parlimenTitle = user.parlimenTitle
                survey.parlimenId = user.parlimenId
                survey.issue = user.issue
                survey.wishlist = user.wishlist
                survey.updated = Date()
                realm.delete(survey.photo)
                realm.delete(survey.video)
                
                for video in user.video{
                    survey.video.append(video)
                }
                
                for photo in user.photo{
                    survey.photo.append(photo)
                }
                
                realm.create(Survey.self, value: survey, update: true)
                
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
                survey.photo = user.photo
                survey.video = user.video
                survey.created = Date()
                survey.updated = Date()
                
                user.survey.append(survey)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTable"), object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
}
