//
//  Video.swift
//  SurveyApp
//
//  Created by ridzuan othman on 26/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit
import RealmSwift

class VideoSurvey: Object {
    @objc dynamic var thumbnail = Data()
    @objc dynamic var url = ""
}
