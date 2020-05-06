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
        nameLabel.text = person.person.name
        imageView.image = person.image
        self.addBorders(edges: .all, color: .black)
        imageHeightConstraints.constant = self.frame.size.height - 30

    }
}
