//
//  User.swift
//  SurveyApp
//
//  Created by ridzuan othman on 05/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class User: Object {

    //User info
    @objc dynamic var isLogin = Bool()
    @objc dynamic var icnumber = ""
    @objc dynamic var name = ""
    @objc dynamic var email = ""
    @objc dynamic var phoneno = ""
    @objc dynamic var rolename = ""
    let parlimen = List<Parlimen>()
    let checklist = List<Checklist>()
    
    //Temporary Survey Data
    @objc dynamic var id = ""
    @objc dynamic var parlimenTitle = ""
    @objc dynamic var parlimenId = ""
    @objc dynamic var categoryTitle = ""
    @objc dynamic var categoryId = ""
    @objc dynamic var issue = ""
    @objc dynamic var wishlist = ""
    let photo = List<Photo>()
    let video = List<VideoSurvey>()
    
    let survey = List<Survey>()
    
    //category
    let categories = List<Categories>()
    
    class var current: User {
        let realm = try! Realm()
        var user = realm.objects(User.self).first
        if(user == nil) {
            user = User()
            try! realm.write {
                realm.add(user!)
            }
        }
        return user!
    }
    
}
