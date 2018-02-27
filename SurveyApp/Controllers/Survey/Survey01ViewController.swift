//
//  Survey01ViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class Survey01ViewController: BaseViewController {

    @IBOutlet weak var parlimenStack: UIStackView!
    @IBOutlet weak var parlimenView: UIView!
    @IBOutlet weak var parlimenLbl: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLbl: UILabel!
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var categoryId = String()
    var parlimentId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("second", title: "Survey Category")
        processNumber(1)
        addShadow(nextBtn)
        
        if User.current.rolename == "PDMLeader"{
            parlimenLbl.text = User.current.parlimen[0].parlimen.capitalized
            parlimentId = User.current.parlimen[0].parlimenCode
            parlimenStack.isHidden = true
        }else{
           parlimenView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChooseBtnClicked(_:))))
        }
        
        if status == "edit"{
            
            parlimenLbl.text = survey.parlimenTitle.capitalized
            categoryLbl.text = survey.categoryTitle
            
            parlimentId = survey.parlimenId
            categoryId = survey.categoryId
        }
        
        categoryView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChooseBtnClicked(_:))))
        
        NotificationCenter.default.addObserver(self, selector:#selector(reloadData(_:)), name:NSNotification.Name(rawValue: "reload"), object:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    @objc func reloadData(_ sender: Notification){
        let userInfo = sender.userInfo as! [String: AnyObject]
        let type = userInfo["type"] as! String
        let index = userInfo["index"]! as! Int
        
        switch type {
        case "Parlimen":
            parlimenLbl.text = "\(User.current.parlimen[index].parlimen.capitalized)"
            parlimentId = User.current.parlimen[index].parlimenCode
        case "Category":
            categoryLbl.text = "\(User.current.categories[index].categoryTitle)"
            categoryId = User.current.categories[index].categoryId
        default:
            break
        }
    }
    
    @objc func onChooseBtnClicked(_ sender: UITapGestureRecognizer){
        let tag = sender.view?.tag
        
        switch tag! {
        case 1:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let survey02VC = storyboard.instantiateViewController(withIdentifier: "PickerVC") as! PickerViewController
            survey02VC.type = "Parlimen"
            self.present(survey02VC, animated: true, completion: nil)
        case 2:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let survey02VC = storyboard.instantiateViewController(withIdentifier: "PickerVC") as! PickerViewController
            survey02VC.type = "Category"
            self.present(survey02VC, animated: true, completion: nil)
        default:
            break
        }
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if parlimenLbl.text == "Select Parlimen" && categoryLbl.text == "Select Category"{
            showErrorMessage("Please select Parlimen and Category")
        }else if parlimenLbl.text == "Select Parlimen"{
            showErrorMessage("Please select Parlimen")
        }else if categoryLbl.text == "Select Category"{
            showErrorMessage("Please select Category")
        }else{
            
            let user = User.current
            
            try! realm.write {
                user.parlimenTitle = (parlimenLbl.text)!
                user.categoryTitle = (categoryLbl.text)!
                user.categoryId = categoryId
                user.parlimenId = parlimentId
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let survey02VC = storyboard.instantiateViewController(withIdentifier: "Survey02VC") as! Survey02ViewController
            survey02VC.status = status
            
            if status == "edit"{
                survey02VC.surveyIndex = surveyIndex
                survey02VC.survey = survey
            }
            
            self.navigationController?.heroNavigationAnimationType = .fade
            self.navigationController?.pushViewController(survey02VC, animated: true)
            
        }
    
    }

}
