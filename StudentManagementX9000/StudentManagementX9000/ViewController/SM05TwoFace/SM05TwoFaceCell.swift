//
//  SM05TwoFaceCell.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 5/5/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit

class SM05TwoFaceCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var checkMarkButton: UIButton!
    @IBOutlet weak var imageViewWidthContraint: NSLayoutConstraint!

    func configureCell(with image: UIImage, isSelected: Bool) {
        imageViewWidthContraint.constant = self.frame.size.height
        checkMarkButton.isSelected = isSelected
        imageView.image = image
        checkMarkButton.backgroundColor = .white
        checkMarkButton.addBorders(edges: .all, color: .black)
    }
}
