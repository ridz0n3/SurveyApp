//
//  SurveyViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import RealmSwift

class SurveyViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var surveyTableView: UITableView!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var filterView: UIView!
    
    var doneRefresh = Bool()
    var survey1 = User.current.survey.sorted(byKeyPath: "updated", ascending: false)
    var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("survey", title: "My Survey")
        
        filterView.layer.borderColor = UIColor.lightGray.cgColor
        filterView.layer.borderWidth = 1
        
        if survey1.count == 0{
            surveyTableView.isHidden = true
            filterView.isHidden = true
        }else{
            surveyTableView.isHidden = false
            filterView.isHidden = false
        }
        
        surveyTableView.estimatedRowHeight = 10
        surveyTableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.reload), name:NSNotification.Name(rawValue: "reloadTable"), object:nil)
        
        if isConnectedToNetwork(){
            Hud.show(view)
            Api.getSurveyList().continueWith(block: { (task) -> Any? in
                Hud.hide()
                if task.succeed{
                    
                    if self.survey1.count != 0{
                        self.survey1 = self.survey1.sorted(byKeyPath: "updated", ascending: false)
                        self.surveyTableView.isHidden = false
                        self.filterView.isHidden = false
                        self.surveyTableView.reloadData()
                    }
                    
                }else{
                    task.showError()
                }
                
                return nil
            })
        }else{
            
            survey1 = survey1.filter("status == %@", "local").sorted(byKeyPath: "updated")
            
            if self.survey1.count == 0{
                self.filterView.isHidden = true
                self.surveyTableView.isHidden = true
                self.surveyTableView.reloadData()
            }
        }
        
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
        self.survey1 = self.survey1.sorted(byKeyPath: "updated", ascending: false)
        filterView.isHidden = false
        surveyTableView.isHidden = false
        surveyTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return survey1.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = surveyTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomSurveyTableViewCell
        
        cell.titleLbl.text = "\(survey1[indexPath.row].parlimenTitle.capitalized) (\(survey1[indexPath.row].categoryTitle))"
        cell.issueLbl.text = "\(survey1[indexPath.row].issue)"
        cell.destinationLbl.text = "\(survey1[indexPath.row].status.capitalized)"
        cell.statusLbl.text = "\(survey1[indexPath.row].processStatus ? "Processed" : "Not Processed")"
        let formater = dateFormater()
        
        if survey1[indexPath.row].status == "local"{
            cell.deleteBtn.isHidden = false
            cell.deleteBtn.addTarget(self, action: #selector(deleteSurvey(_:)), for: .touchUpInside)
            cell.deleteBtn.tag = indexPath.row
        }else{
            cell.deleteBtn.isHidden = true
        }
        
        cell.dateCreatedLbl.text = "Created at \(formater.string(from: survey1[indexPath.row].created))"
        cell.dateUpdatedLbl.text = "Updated at \(formater.string(from: survey1[indexPath.row].updated))"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        try! realm.write {
            
            let user = User.current
            let tempSurvey = survey1[indexPath.row]
            
            user.id = tempSurvey.id
            user.categoryTitle = tempSurvey.categoryTitle
            user.categoryId = tempSurvey.categoryId
            user.parlimenTitle = tempSurvey.parlimenTitle
            user.parlimenId = tempSurvey.parlimenId
            user.issue = tempSurvey.issue
            user.wishlist = tempSurvey.wishlist
            user.updateImg = false
            user.updateVideo = false
            realm.delete(user.photo)
            realm.delete(user.video)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let survey01VC = storyboard.instantiateViewController(withIdentifier: "Survey01VC") as! Survey01ViewController
            survey01VC.status = "edit"
            survey01VC.survey = survey1[indexPath.row]
            survey01VC.surveyIndex = indexPath.row
            self.navigationController?.heroNavigationAnimationType = .cover(direction: .up )
            self.navigationController?.pushViewController(survey01VC, animated: true)
            
        }
        
    }
    
    @objc func deleteSurvey(_ sender: UIButton){
        
        if !doneRefresh{
            let tag = sender.tag
            confirmDelete(tag)
        }
        
    }
    
    @objc func confirmDelete(_ tag: Int){
        
        try! realm.write {
            
            var deadlineTime = DispatchTime.now()
            
            if survey1.count > 0{
                deadlineTime = deadlineTime + .seconds(1)
                let tempSurvey = survey1[tag]
                
                realm.delete(tempSurvey)
                
                self.doneRefresh = true
                self.surveyTableView.beginUpdates()
                let indexPath = IndexPath(row: tag, section: 0)
                self.surveyTableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                self.surveyTableView.endUpdates()
            }
            
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                
                self.surveyTableView.reloadData()
                self.doneRefresh = false
            }
            
        }
        
    }
    
    @objc func filterDate(_ date: Date){
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd"
        let newDate = formater.string(from: date).components(separatedBy: " ")
        let tempSurvey = User.current.survey.sorted(byKeyPath: "updated", ascending: false)
        let filteredSurvey = tempSurvey.filter("createdString == %@", newDate[0])
        
        if filteredSurvey.count != 0{
            survey1 = filteredSurvey
            surveyTableView.reloadData()
            
            surveyTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
            surveyTableView.isHidden = false
        }else{
             surveyTableView.isHidden = true
        }
    }
    
    @IBAction func resetBtnPressed(_ sender: Any) {
        selectedDate = Date()
        dateBtn.setTitle("Select Date", for: .normal)
        survey1 = User.current.survey.sorted(byKeyPath: "updated", ascending: false)
        surveyTableView.reloadData()
        surveyTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
    @IBAction func filterBtnPressed(_ sender: Any) {
        let datePicker = ActionSheetDatePicker(title: "Filter by Date at:", datePickerMode: UIDatePickerMode.date, selectedDate: selectedDate, doneBlock: {
            picker, value, index in
            
            let formater = DateFormatter()
            formater.dateFormat = "dd-MMM-yyyy"
            
            self.selectedDate = value as! Date
            self.dateBtn.setTitle("\(formater.string(from: value as! Date))", for: .normal)
            self.filterDate(value as! Date)
            
            return
        }, cancel: { ActionStringCancelBlock in return }, origin: dateBtn)
        
        datePicker?.maximumDate = Date()
        
        datePicker?.show()
    }
}
