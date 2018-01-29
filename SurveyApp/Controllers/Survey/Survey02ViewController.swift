//
//  Survey02ViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class Survey02ViewController: BaseViewController {

    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var issueView: UIView!
    @IBOutlet weak var issueTextView: UITextView!
    @IBOutlet weak var clearBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarSetup("second", title: "Survey Issue")
        processNumber(2)
        addShadow(nextBtn)
        addShadow(issueView)
        addShadow(clearBtn)
        
        if status == "edit"{
            issueTextView.text = User.current.survey[surveyIndex].issue
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if issueTextView.text == ""{
            showErrorMessage("Please fill your survey issue")
        }else{
            
            let user = User.current
            
            try! realm.write {
                user.issue = issueTextView.text
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let survey03VC = storyboard.instantiateViewController(withIdentifier: "Survey03VC") as! Survey03ViewController
            survey03VC.status = status
            
            if status == "edit"{
                survey03VC.surveyIndex = surveyIndex
            }
            
            self.navigationController?.heroNavigationAnimationType = .fade
            self.navigationController?.pushViewController(survey03VC, animated: true)
        }
        
    }
    
    @IBAction func clearBtnPressed(_ sender: Any) {
        issueTextView.text = ""
    }
}
