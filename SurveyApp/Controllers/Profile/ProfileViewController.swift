//
//  ProfileViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 03/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    let user = User.current
    var titleSection = [String]()
    var placeholder = [[String]]()
    var textLbl = [[String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSetup("first", title: "Profile")
        
        
        if user.rolename == "PDMLeader"{
            
            let parlimen = user.parlimen[0]
            
            titleSection = ["Personal Info.", "Role Info."]//, "Parlimen Info."]
            
            placeholder = [
                ["Name", "Phone Number", "Email"],
                ["Role", "PDM"]
            ]
            textLbl = [
                [user.name, user.phoneno, user.email],
                [user.rolename, parlimen.pdm]
            ]
        }else{
            
            titleSection = ["Personal Info.", "Role Info.", "Parlimen Info."]
            
            placeholder = [
                ["Name", "Phone Number", "Email"],
                ["Role"]//,
                //["Parliment", "PDM", "State"]
            ]
            
            let parlimen = user.parlimen
            var parName = [String]()
            
            for data in parlimen{
                parName.append(data.parlimen)
            }
            
            textLbl = [
                [user.name, user.phoneno, user.email],
                [user.rolename],
                parName
            ]
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

    func numberOfSections(in tableView: UITableView) -> Int {
        return titleSection.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textLbl[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2{
            return 30
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)?[2] as! TitleSectionView
        header.titleLbl.text = "\(titleSection[section])"
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            cell.textLabel?.text = textLbl[indexPath.section][indexPath.row].capitalized
            cell.textLabel?.textColor = UIColor.darkGray
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomProfileTableViewCell
            cell.infoTxtField.text = textLbl[indexPath.section][indexPath.row].capitalized
            cell.infoTxtField.titleLabel.text = placeholder[indexPath.section][indexPath.row].capitalized
            return cell
        }

    }
    
    @IBAction func logoutBtnPressed(_ sender: Any) {
        
        Api.logout()
        
    }
}
