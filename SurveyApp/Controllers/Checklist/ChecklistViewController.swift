//
//  ChecklistViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class ChecklistViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var checklistTableView: UITableView!
    @IBOutlet weak var checklistView: UIStackView!
    
    var checklist = List<Checklist>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("first", title: "My Checklist")
        
        checklistTableView.estimatedRowHeight = 10
        checklistTableView.rowHeight = UITableViewAutomaticDimension
        
        if isConnectedToNetwork(){
            getCheckList()
        }else{
            let tempList = User.current.checklist.sorted(byKeyPath: "checklist_text")
            let converted = tempList.reduce(List<Checklist>()) { (list, element) -> List<Checklist> in
                list.append(element)
                return list
            }
            
            self.checklist = converted
            self.checklistTableView.reloadData()
            
            if self.checklist.count == 0{
                self.checklistView.isHidden = true
            }else{
                self.checklistView.isHidden = false
            }
        }
        
        if checklist.count == 0{
            checklistView.isHidden = true
        }else{
            checklistView.isHidden = false
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
    
    @objc func getCheckListSubmission(){
        
        Api.getChecklistSubmission().continueWith(block: { (task) -> Any? in
            Hud.hide()
            if task.succeed{
                let tempList = User.current.checklist.sorted(byKeyPath: "checklist_text")
                let converted = tempList.reduce(List<Checklist>()) { (list, element) -> List<Checklist> in
                    list.append(element)
                    return list
                }
                
                self.checklist = converted
                self.checklistTableView.reloadData()
                
                if self.checklist.count == 0{
                    self.checklistView.isHidden = true
                }else{
                    self.checklistView.isHidden = false
                }
            }else{
                task.showError()
            }
            return nil
        })
        
    }
    
    @objc func getCheckList(){
        
        Hud.show(view)
        Api.getChecklist().continueWith(block: { (task) -> Any? in
            if task.succeed{
                self.getCheckListSubmission()
            }else{
                Hud.hide()
                task.showError()
            }
            return nil
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return checklist.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist[section].child.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checklistTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomChecklistTableViewCell
        let data = checklist[indexPath.section].child[indexPath.row]
        cell.checklistcheckImg.image = data.progressStatus == "yes" ? UIImage(named: "checkImg") : UIImage(named: "uncheckImg")
        addShadow(cell.commentTxtView)
        cell.commentTxtView.isHidden = data.progressStatus == "yes" ? false : true
        cell.commentTxtView.text = data.comment
        cell.commentTxtView.tag = indexPath.row
        cell.commentTxtView.accessibilityHint = "\(indexPath.section)"
        cell.checklistLbl.text = data.checklist_text
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?[2] as! TitleSectionView
        header.titleLbl.text = checklist[section].checklist_text
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
        
        try! realm.write {
            let data = checklist[indexPath.section]
            let child = data.child[indexPath.row]
            
            child.progressStatus = child.progressStatus == "yes" ? "no" : "yes"
            child.isEditing = true
            data.isEditing = true
            
            realm.create(Checklist.self, value: data, update: true)
            realm.create(ChecklistChild.self, value: child, update: true)
            
            let contentOffset = checklistTableView.contentOffset
            checklistTableView.reloadData()
            checklistTableView.layoutIfNeeded()
            checklistTableView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let section = Int(textView.accessibilityHint!)
        let tag = textView.tag
        try! realm.write {
            let data = checklist[section!]
            let child = data.child[tag]
            
            data.isEditing = true
            child.comment = textView.text
            child.isEditing = true
            
            realm.create(Checklist.self, value: data, update: true)
            realm.create(ChecklistChild.self, value: child, update: true)
        }
    }
    
    func reloadCheckList(){
        
        checklist = User.current.checklist
        checklistTableView.reloadData()
        
    }
    
    @IBAction func submitBtnPressed(_ sender: Any) {
        
        view.endEditing(true)
        
        if isConnectedToNetwork(){
            let checklist = User.current.checklist
            var content = [String]()
            
            for data in checklist{
                for child in data.child{
                    if child.isEditing || child.isExisting{
                        let str = "{\"itemid\":\"\(child.itemid)\",\"comment\":\"\(child.comment)\",\"check\":\"\(child.progressStatus)\"}"
                        content.append(str)
                    }
                }
            }
            
            if content.count != 0{
                
                Hud.show(view)
                Api.postChecklist(content).continueOnSuccessWith(block: { (task) -> Any? in
                    Hud.hide()
                    if task.succeed{
                        showToastMessage("Success add/update checklist")
                    }else{
                        task.showError()
                    }
                    
                    return nil
                })
                
            }
        }
        
    }
}
