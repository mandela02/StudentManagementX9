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

    func configureCell(with image: UIImage) {
        imageView.image = image
    }
}
