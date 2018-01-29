//
//  PhotoTableViewCell.swift
//  SurveyApp
//
//  Created by ridzuan othman on 06/01/2018.
//  Copyright © 2018 ridzuan othman. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {

    @IBOutlet weak var uploadedImgView: UIImageView!
    @IBOutlet weak var changeBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var playImg: UIImageView!
    @IBOutlet weak var playBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
