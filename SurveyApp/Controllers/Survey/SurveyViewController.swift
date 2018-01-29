//
//  SurveyViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class SurveyViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var surveyTableView: UITableView!
    
    var survey = User.current.survey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("survey", title: "My Survey")
        
        if survey.count == 0{
            surveyTableView.isHidden = true
        }else{
            surveyTableView.isHidden = false
        }
        
        surveyTableView.estimatedRowHeight = 10
        surveyTableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reload), name:NSNotification.Name(rawValue: "reloadTable"), object:nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.layer.zPosition = 0
    }
    
    override func addBtnPressed() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let survey01VC = storyboard.instantiateViewController(withIdentifier: "Survey01VC") as! Survey01ViewController
        survey01VC.status = "add"
        self.navigationController?.heroNavigationAnimationType = .cover(direction: .up )
        self.navigationController?.pushViewController(survey01VC, animated: true)
        
    }

    @objc func reload(){
        survey = User.current.survey
        surveyTableView.isHidden = false
        surveyTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return survey.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = surveyTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomSurveyTableViewCell
        
        cell.titleLbl.text = "\(survey[indexPath.row].parlimenTitle.capitalized) (\(survey[indexPath.row].categoryTitle))"
        cell.issueLbl.text = "\(survey[indexPath.row].issue)"
        
        let formater = DateFormatter()
        formater.locale = Locale(identifier: "en_GB")
        formater.timeZone = NSTimeZone.local
        formater.dateFormat = "dd-MMM-yyyy hh:mm:ss"
        
        cell.dateCreatedLbl.text = "Created at \(formater.string(from: survey[indexPath.row].created))"
        cell.dateUpdatedLbl.text = "Updated at \(formater.string(from: survey[indexPath.row].updated))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        try! realm.write {
            let user = User.current
            let survey = User.current.survey[indexPath.row]
            
            user.id = survey.id
            user.categoryTitle = survey.categoryTitle
            user.categoryId = survey.categoryId
            user.parlimenTitle = survey.parlimenTitle
            user.parlimenId = survey.parlimenId
            user.issue = survey.issue
            user.wishlist = survey.wishlist
            realm.delete(survey.photo)
            realm.delete(survey.video)
            
            for video in user.video{
                survey.video.append(video)
            }
            
            for photo in user.photo{
                survey.photo.append(photo)
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let survey01VC = storyboard.instantiateViewController(withIdentifier: "Survey01VC") as! Survey01ViewController
            survey01VC.status = "edit"
            survey01VC.surveyIndex = indexPath.row
            self.navigationController?.heroNavigationAnimationType = .cover(direction: .up )
            self.navigationController?.pushViewController(survey01VC, animated: true)
            
        }
        
    }
}
