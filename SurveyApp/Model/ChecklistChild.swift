//
//  ChecklistChild.swift
//  SurveyApp
//
//  Created by ridzuan othman on 08/02/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class ChecklistChild: Object {

    @objc dynamic var checklistid = ""
    @objc dynamic var itemid = ""
    @objc dynamic var checklist_text = ""
    @objc dynamic var progressStatus = ""
    @objc dynamic var comment = ""
    @objc dynamic var location = ""
    @objc dynamic var isExisting = Bool()
    @objc dynamic var isEditing = Bool()
    
    override static func primaryKey() -> String? {
        return "checklistid"
    }
    
}
