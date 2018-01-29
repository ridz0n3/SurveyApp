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

    @objc dynamic var checklistid = 0
    @objc dynamic var checklist_text = ""
    @objc dynamic var progressStatus = ""
    @objc dynamic var comment = ""
    
    override static func primaryKey() -> String? {
        return "checklistid"
    }
}
