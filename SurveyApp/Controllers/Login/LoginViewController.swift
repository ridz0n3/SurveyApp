//
//  LoginViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class LoginViewController: BaseViewController {

    @IBOutlet weak var emailTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTxtField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func getUserInfo(){
        Api.getUserInfo(self.emailTxtField.text!).continueWith(block: { (task2) -> Any? in
            if task2.succeed{
                self.getCategories()
            }else{
                Hud.hide()
                task2.showError()
            }
            return nil
        })
    }
    
    @objc func getCategories(){
        Api.getCategory().continueWith(block: { (task) -> Any? in
            Hud.hide()
            if task.succeed{
                let viewController = UIApplication.shared.delegate as! AppDelegate
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let FirstNavigationVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                viewController.window!.rootViewController = FirstNavigationVC
            }else{
                task.showError()
            }
            return nil
        })
    }
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        if emailTxtField.text == "" && passwordTxtField.text == ""{
            showErrorMessage("Please fill all fields")
        }else if emailTxtField.text == ""{
            showErrorMessage("Please fill IC Number field")
        }else if passwordTxtField.text == ""{
            showErrorMessage("Please fill Password field")
        }else{
            
            Hud.show(view)
            Api.login(emailTxtField.text!, passwordTxtField.text!).continueWith(block: { (task) -> Any? in
                if task.succeed{
                    self.getUserInfo()
                }else{
                    Hud.hide()
                    task.showError()
                }
                
                return nil
            })
            
        }
        
    }

}
