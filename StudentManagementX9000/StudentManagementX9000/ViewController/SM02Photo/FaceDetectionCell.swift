//
//  FaceDetectionCell.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/18/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit

class FaceDetectionCell: UITableViewCell {

    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var emotionLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(with model: IdentificationResult) {
        faceImageView.image = UIImage(named: "emptyAvatar")
        genderLabel.text = model.person.name
        emotionLabel.text = model.person.personId
        ageLabel.text = "confidence \(model.confidence)"
    }
}
