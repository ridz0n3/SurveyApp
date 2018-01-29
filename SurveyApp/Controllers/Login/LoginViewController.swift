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
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        
        if emailTxtField.text == "" && passwordTxtField.text == ""{
            showErrorMessage("Please fill all fields")
        }else if emailTxtField.text == ""{
            showErrorMessage("Please fill email field")
        }else if passwordTxtField.text == ""{
            showErrorMessage("Please fill password field")
        }else{
            
            Hud.show(view)
            Api.login(emailTxtField.text!, passwordTxtField.text!).continueWith(block: { (task) -> Any? in
                if task.succeed{
                    
                    Api.getUserInfo(self.emailTxtField.text!).continueWith(block: { (task2) -> Any? in
                        Hud.hide()
                        if task2.succeed{
                            let viewController = UIApplication.shared.delegate as! AppDelegate
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let FirstNavigationVC = storyboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeViewController
                            viewController.window!.rootViewController = FirstNavigationVC
                        }else{
                            task2.showError()
                        }
                        return nil
                    })
                    
                }else{
                    Hud.hide()
                    task.showError()
                }
                
                return nil
            })
            
        }
        
    }

}
