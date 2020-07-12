//
//  SM04NewPersionCollectionViewCell.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/20/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit

class SM04NewPersionCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageWidthConstraints: NSLayoutConstraint!

    func configureCell(with image: StorageImage) {
        imageView.image = image.image
        imageWidthConstraints.constant = self.frame.size.height
        if image.isSelected {
            imageView.addBorders(edges: .all,
                                 color: .red,
                                 inset: 0,
                                 thickness: 5)
        } else {
            imageView.removeAllSubviews()
        }
    }
}
