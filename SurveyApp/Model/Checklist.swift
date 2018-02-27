//
//  Checklist.swift
//  SurveyApp
//
//  Created by ridzuan othman on 25/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class Checklist: Object {

    @objc dynamic var checklistid = ""
    @objc dynamic var itemid = ""
    @objc dynamic var checklist_text = ""
    @objc dynamic var isEditing = Bool()
    var child = List<ChecklistChild>()
    
    override static func primaryKey() -> String? {
        return "checklistid"
    }
}
