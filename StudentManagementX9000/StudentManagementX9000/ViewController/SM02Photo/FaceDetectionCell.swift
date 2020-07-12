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

    func configureCell(with model: PhotoCell) {
        guard model.result.confidence != 0.0 else {
            faceImageView.image = model.result.model?.faceImage
            genderLabel.text = "Not Found"
            emotionLabel.text = "Not Found"
            ageLabel.text = "Not Found"
            return
        }
        faceImageView.image = model.result.model?.faceImage
        genderLabel.text = "Student name: \(model.student.studentName)"
        emotionLabel.text = "Mail: \(model.student.studentMail)"
        ageLabel.text = "ID Number: \(model.student.studentId)"
    }
}
