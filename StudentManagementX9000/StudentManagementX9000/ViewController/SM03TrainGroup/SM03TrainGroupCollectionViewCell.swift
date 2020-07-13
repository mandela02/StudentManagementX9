//
//  SM03TrainGroupCollectionViewCell.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/20/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit

class SM03TrainGroupCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageHeightConstraints: NSLayoutConstraint!

    func configureCell(with person: Person) {
        nameLabel.text = person.person.studentName
        imageView.image = person.image
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.setConner(radius: 4.0)
        imageView.setConner(radius: 4.0)
        imageHeightConstraints.constant = self.frame.size.height - 30

    }
}
