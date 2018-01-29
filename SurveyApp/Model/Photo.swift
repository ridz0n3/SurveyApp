//
//  Photo.swift
//  SurveyApp
//
//  Created by ridzuan othman on 14/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class Photo: Object {
    @objc dynamic var imgData = Data()
    @objc dynamic var imgUrl = ""
}
