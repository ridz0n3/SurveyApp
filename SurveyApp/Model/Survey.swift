//
//  Survey.swift
//  SurveyApp
//
//  Created by ridzuan othman on 05/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class Survey: Object {

    @objc dynamic var id = ""
    @objc dynamic var status = ""
    @objc dynamic var parlimenTitle = ""
    @objc dynamic var parlimenId = ""
    @objc dynamic var categoryTitle = ""
    @objc dynamic var categoryId = ""
    @objc dynamic var issue = ""
    @objc dynamic var wishlist = ""
    var photo = List<Photo>()
    var video = List<VideoSurvey>()
    
    @objc dynamic var created = Date(timeIntervalSince1970: 1)
    @objc dynamic var updated = Date(timeIntervalSince1970: 1)
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
