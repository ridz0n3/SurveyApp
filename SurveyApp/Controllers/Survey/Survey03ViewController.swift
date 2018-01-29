//
//  Survey03ViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class Survey03ViewController: BaseViewController {

    @IBOutlet weak var wishlistView: UIView!
    @IBOutlet weak var wishlistTextview: UITextView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("second", title: "Survey Wishlist")
        processNumber(3)
        
        addShadow(nextBtn)
        addShadow(clearBtn)
        addShadow(wishlistView)
        
        if status == "edit"{
            wishlistTextview.text = User.current.survey[surveyIndex].wishlist
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.tabBarController?.tabBar.layer.zPosition = -1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        
        let user = User.current
        
        try! realm.write {
            user.wishlist = wishlistTextview.text
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let survey04VC = storyboard.instantiateViewController(withIdentifier: "Survey04VC") as! Survey04ViewController
        survey04VC.status = status
        
        if status == "edit"{
            survey04VC.surveyIndex = surveyIndex
        }
        
        self.navigationController?.heroNavigationAnimationType = .fade
        self.navigationController?.pushViewController(survey04VC, animated: true)
    }
    
    @IBAction func clearBtnPressed(_ sender: Any) {
        wishlistTextview.text = ""
    }
}
