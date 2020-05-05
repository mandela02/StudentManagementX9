//
//  SM05TwoFaceViewController.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 5/5/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit
import ProjectOxfordFace
import RxSwift
import RxCocoa

class SM05TwoFaceViewController: BaseViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var backGroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var confirmButton: UIButton!

    @IBOutlet weak var imageCollectionView: UICollectionView!

    var newPersonParentViewController: SM04NewPersonViewController?
    var faces: [MPOFace] = []
    var selectedFace: MPOFace?
    var studentId = ""
    var image: UIImage?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        backGroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        titleLabel.text = "Choose your face!?"
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard let selectedFace = self.selectedFace, let image = self.image else {
                return
            }
            let croppedImage = FaceApiHelper.shared.cutImage(from: selectedFace, of: image)
            self.newPersonParentViewController?.viewModel
                .addNewImage(image: croppedImage)
            FaceApiHelper.shared
                .trainPerson(image: image,
                             with: selectedFace,
                             studentId: self.studentId)
                .subscribe().disposed(by: self.disposeBag)
        }
    }
}

extension SM05TwoFaceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return faces.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: SM05TwoFaceCell.className,
                            for: indexPath) as? SM05TwoFaceCell else {
            return UICollectionViewCell()
        }
        guard let image = image else { return UICollectionViewCell() }
        var imageList: [UIImage] = []
        for face in faces {
            imageList.append(FaceApiHelper.shared.cutImage(from: face, of: image))
        }
        cell.configureCell(with: imageList[indexPath.item], isSelected: faces[indexPath.item] == selectedFace)
        return cell
    }
}

extension SM05TwoFaceViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFace = faces[indexPath.item]
        collectionView.reloadData()
    }
}

extension SM05TwoFaceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = CollectionView.sectionInsets.left
            + CollectionView.sectionInsets.right
            + (CollectionView.sectionInsets.left * (CollectionView.numberOfCellinRow - 1))
        let size = Int((containerView.bounds.width - padding - 40) / CollectionView.numberOfCellinRow)
        return CGSize(width: size, height: size)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionView.sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionView.sectionInsets.left
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionView.sectionInsets.bottom
    }
}
