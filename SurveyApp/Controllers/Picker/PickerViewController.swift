//
//  PickerViewController.swift
//  SurveyApp
//
//  Created by ridzuan othman on 04/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class PickerViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var heightConstraints: NSLayoutConstraint!
    @IBOutlet weak var pickerTableView: UITableView!
    
    var type = String()
    var typeDetails = [String]()
    var categories = List<Categories>()
    var parlimen = List<Parlimen>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if type == "Category"{
            categories = User.current.categories
        }else{
            parlimen = User.current.parlimen
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        var height = CGFloat()
        
        if type == "Category"{
            height = CGFloat(50 * categories.count)
        }else{
            height = CGFloat(50 * parlimen.count)
        }
        
        if height <= 390{
            heightConstraints.constant = height
        }else{
            heightConstraints.constant = 390
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if type == "Category"{
            return categories.count
        }else{
            return parlimen.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pickerTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomPickerTableViewCell
        
        if type == "Category"{
            cell.titleDetail.text = categories[indexPath.row].categoryTitle.capitalized
        }else{
            cell.titleDetail.text = parlimen[indexPath.row].parlimen.capitalized
        }
        
        cell.titleDetail.heroID = type
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil, userInfo: ["type": self.type, "index": indexPath.row])
        self.dismiss(animated: true, completion: nil)
        
    }

}
