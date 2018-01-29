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
    
    var checklist = List<Checklist>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("first", title: "My Checklist")
        
        checklistTableView.estimatedRowHeight = 10
        checklistTableView.rowHeight = UITableViewAutomaticDimension
        
        getCheckList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.layer.zPosition = 0
    }
    
    @objc func getCheckList(){
        
        Hud.show(view)
        Api.getChecklist().continueOnSuccessWith { (task) -> Any? in
            Hud.hide()
            if task.succeed{
                self.checklist = User.current.checklist
                self.checklistTableView.reloadData()
            }else{
                task.showError()
            }
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checklistTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomChecklistTableViewCell
        let data = checklist[indexPath.row]
        cell.checklistcheckImg.image = data.progressStatus == "yes" ? UIImage(named: "checkImg") : UIImage(named: "uncheckImg")
        addShadow(cell.commentTxtView)
        cell.commentTxtView.isHidden = data.progressStatus == "yes" ? false : true
        cell.commentTxtView.text = data.comment
        cell.commentTxtView.tag = indexPath.row
        cell.checklistLbl.text = data.checklist_text
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        view.endEditing(true)
        
        try! realm.write {
            let data = checklist[indexPath.row]
            
            data.progressStatus = data.progressStatus == "yes" ? "no" : "yes"
            
            realm.create(Checklist.self, value: data, update: true)
            
            let contentOffset = checklistTableView.contentOffset
            checklistTableView.reloadData()
            checklistTableView.layoutIfNeeded()
            checklistTableView.setContentOffset(contentOffset, animated: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let tag = textView.tag
        try! realm.write {
            let data = checklist[tag]
            
            data.comment = textView.text
            
            realm.create(Checklist.self, value: data, update: true)
        }
    }
}
