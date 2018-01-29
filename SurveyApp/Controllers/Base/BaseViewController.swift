//
//  BaseViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import Hero

class BaseViewController: UIViewController {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var view6: UIView!
    
    var status = String()
    var surveyIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if status == "edit"{
            view1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSelect(_:))))
            view1.tag = 1
            view2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSelect(_:))))
            view2.tag = 2
            view3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSelect(_:))))
            view3.tag = 3
            view4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSelect(_:))))
            view4.tag = 4
            view5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSelect(_:))))
            view5.tag = 5
            view6.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewSelect(_:))))
            view6.tag = 6
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func viewSelect(_ sender: UITapGestureRecognizer){
        let tag = sender.view?.tag
        
        switch tag! {
        case 1:
            changeVC(Survey01ViewController.classForCoder())
        case 2:
            changeVC(Survey02ViewController.classForCoder())
        case 3:
            changeVC(Survey03ViewController.classForCoder())
        case 4:
            changeVC(Survey04ViewController.classForCoder())
        case 5:
            changeVC(Survey05ViewController.classForCoder())
        case 6:
            changeVC(Survey06ViewController.classForCoder())
        default:
            break
        }
    }
    
    func changeVC(_ newVC: AnyClass){
    
        var isFound = Bool()
        var tempVC = UIViewController()
        for vc in (navigationController?.viewControllers)!{
            if vc.classForCoder == newVC{
                isFound = true
                tempVC = vc
            }
        }
        
        if navigationController?.viewControllers.last?.classForCoder != newVC{
            
            if isFound{
                navigationController?.popToViewController(tempVC, animated: true)
            }else{
                
                if newVC == Survey01ViewController.classForCoder(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let survey01VC = storyboard.instantiateViewController(withIdentifier: "Survey01VC") as! Survey01ViewController
                    survey01VC.status = status
                    survey01VC.surveyIndex = surveyIndex
                    self.navigationController?.heroNavigationAnimationType = .fade
                    self.navigationController?.pushViewController(survey01VC, animated: true)
                }else if newVC == Survey02ViewController.classForCoder(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let survey02VC = storyboard.instantiateViewController(withIdentifier: "Survey02VC") as! Survey02ViewController
                    survey02VC.status = status
                    survey02VC.surveyIndex = surveyIndex
                    self.navigationController?.heroNavigationAnimationType = .fade
                    self.navigationController?.pushViewController(survey02VC, animated: true)
                }else if newVC == Survey03ViewController.classForCoder(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let survey03VC = storyboard.instantiateViewController(withIdentifier: "Survey03VC") as! Survey03ViewController
                    survey03VC.status = status
                    survey03VC.surveyIndex = surveyIndex
                    self.navigationController?.heroNavigationAnimationType = .fade
                    self.navigationController?.pushViewController(survey03VC, animated: true)
                }else if newVC == Survey04ViewController.classForCoder(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let survey04VC = storyboard.instantiateViewController(withIdentifier: "Survey04VC") as! Survey04ViewController
                    survey04VC.status = status
                    survey04VC.surveyIndex = surveyIndex
                    self.navigationController?.heroNavigationAnimationType = .fade
                    self.navigationController?.pushViewController(survey04VC, animated: true)
                }else if newVC == Survey05ViewController.classForCoder(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let survey05VC = storyboard.instantiateViewController(withIdentifier: "Survey05VC") as! Survey05ViewController
                    survey05VC.status = status
                    survey05VC.surveyIndex = surveyIndex
                    self.navigationController?.heroNavigationAnimationType = .fade
                    self.navigationController?.pushViewController(survey05VC, animated: true)
                }else if newVC == Survey06ViewController.classForCoder(){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let survey06VC = storyboard.instantiateViewController(withIdentifier: "Survey06VC") as! Survey06ViewController
                    survey06VC.status = status
                    survey06VC.surveyIndex = surveyIndex
                    self.navigationController?.heroNavigationAnimationType = .fade
                    self.navigationController?.pushViewController(survey06VC, animated: true)
                }
                
            }
            
        }
        
    }
    
    func processNumber(_ process: Int){
        
        view1.layer.borderColor = UIColor.black.cgColor
        view1.layer.borderWidth = 1
        view2.layer.borderColor = UIColor.black.cgColor
        view2.layer.borderWidth = 1
        view3.layer.borderColor = UIColor.black.cgColor
        view3.layer.borderWidth = 1
        view4.layer.borderColor = UIColor.black.cgColor
        view4.layer.borderWidth = 1
        view5.layer.borderColor = UIColor.black.cgColor
        view5.layer.borderWidth = 1
        view6.layer.borderColor = UIColor.black.cgColor
        view6.layer.borderWidth = 1
        
        switch process {
        case 1:
            view1.backgroundColor = UIColor.lightGray
            view2.backgroundColor = UIColor.white
            view3.backgroundColor = UIColor.white
            view4.backgroundColor = UIColor.white
            view5.backgroundColor = UIColor.white
            view6.backgroundColor = UIColor.white
        case 2:
            view1.backgroundColor = UIColor.white
            view2.backgroundColor = UIColor.lightGray
            view3.backgroundColor = UIColor.white
            view4.backgroundColor = UIColor.white
            view5.backgroundColor = UIColor.white
            view6.backgroundColor = UIColor.white
        case 3:
            view1.backgroundColor = UIColor.white
            view2.backgroundColor = UIColor.white
            view3.backgroundColor = UIColor.lightGray
            view4.backgroundColor = UIColor.white
            view5.backgroundColor = UIColor.white
            view6.backgroundColor = UIColor.white
        case 4:
            view1.backgroundColor = UIColor.white
            view2.backgroundColor = UIColor.white
            view3.backgroundColor = UIColor.white
            view4.backgroundColor = UIColor.lightGray
            view5.backgroundColor = UIColor.white
            view6.backgroundColor = UIColor.white
        case 5:
            view1.backgroundColor = UIColor.white
            view2.backgroundColor = UIColor.white
            view3.backgroundColor = UIColor.white
            view4.backgroundColor = UIColor.white
            view5.backgroundColor = UIColor.lightGray
            view6.backgroundColor = UIColor.white
        case 6:
            view1.backgroundColor = UIColor.white
            view2.backgroundColor = UIColor.white
            view3.backgroundColor = UIColor.white
            view4.backgroundColor = UIColor.white
            view5.backgroundColor = UIColor.white
            view6.backgroundColor = UIColor.lightGray
        default:break
        }
        
    }
    
    func navigationBarSetup(_ level: String, title: String){
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        
        if level == "second"{
            
            let backBtnView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?[0] as! BackBtnView
            backBtnView.backgroundColor = UIColor.clear
            backBtnView.backBtn.addTarget(self, action: #selector(self.backBtnPressed), for: UIControlEvents.touchUpInside)
            let rightBtn = UIBarButtonItem(customView: backBtnView)
            self.navigationItem.leftBarButtonItem = rightBtn
            
        }
        
        if level == "survey"{
            
            let addBtnView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?[1] as! AddBtnView
            addBtnView.backgroundColor = UIColor.clear
            addBtnView.addBtn.addTarget(self, action: #selector(self.addBtnPressed), for: UIControlEvents.touchUpInside)
            let rightBtn = UIBarButtonItem(customView: addBtnView)
            self.navigationItem.rightBarButtonItem = rightBtn
            
        }
        
        self.navigationItem.title = title
        
    }

    @objc func backBtnPressed(){
        
        if navigationController?.viewControllers.last?.classForCoder == Survey01ViewController.classForCoder(){
            self.navigationController?.heroNavigationAnimationType = .uncover(direction: .down)
        }else{
            self.navigationController?.heroNavigationAnimationType = .fade
        }
        
        hero_dismissViewController()
    }
    
    @objc func addBtnPressed(){ }
    
}
