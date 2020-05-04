//
//  SM02PhotoViewController.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/18/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import FirebaseUI

class SM02PhotoViewController: BaseViewController {

    private let reuseIdentifier = "FaceCell"

    @IBOutlet weak var openGalleryButton: UIButton!
    @IBOutlet weak var openCameraButton: UIButton!

    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var personListTableView: UITableView!

    private let disposeBag = DisposeBag()

    let viewModel = SM02PhotoViewModel()

    deinit {
        print("deinit")
    }

    override func configureView() {
        openCameraButton.setTitle("open Camera", for: .normal)
        openGalleryButton.setTitle("open Gallery", for: .normal)
        noImageLabel.text = "No Image Selected"
        noImageLabel.setBorder(color: .black, thickness: 1.0)
        personListTableView.setBorder(color: .black, thickness: 1.0)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }

    override func configureObservers() {
        initTableView()
//        viewModel.faceDataList.subscribe(onNext: { [weak self] models in
//            guard let self = self else { return }
//            for model in models {
//                if let image = self.imageView.image,
//                    let rect = model.rect {
//                    self.imageView.image = image.drawRectangleOnImage(rect: rect)
//                }
//            }
//        }).disposed(by: disposeBag)
    }

    private func openImagePicker(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    @IBAction func openGalleryButtonPressed(_ sender: Any) {
        openImagePicker(source: .photoLibrary)
    }

    @IBAction func openCameraButtonPressed(_ sender: Any) {
        openImagePicker(source: .camera)
    }
}

extension SM02PhotoViewController {
    private func initTableView() {
        let datasource = RxTableViewSectionedReloadDataSource<FaceSectionModel>(configureCell: { [weak self] _, _, indexPath, sectionModel -> UITableViewCell in
            guard let self = self else { return UITableViewCell() }
            if let cell = self.personListTableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier,
                                                                     for: indexPath) as? FaceDetectionCell {
                cell.configureCell(with: sectionModel)
                return cell
            }
            return UITableViewCell()
        })
        viewModel
            .faceResult
            .bind(to: personListTableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
    }
}

extension SM02PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        noImageLabel.isHidden = true
        imageView.image = image
        viewModel.faceDataList.accept([])
        picker.dismiss(animated: true, completion: nil)
        ProgressHelper.shared.show()
        FaceApiHelper.shared.detect(image: image).subscribe(onNext: { [weak self] faceCollection in
            guard let self = self else {
                ProgressHelper.shared.hide()
                return
            }
            guard let faceCollection = faceCollection else {
                ProgressHelper.shared.hide()
                return
            }
            FaceApiHelper.shared.identification(with: faceCollection,
                                                image: image)
                .subscribe(onNext: { identificationResults in
                    self.viewModel.faceDataList.accept(identificationResults)
                    ProgressHelper.shared.hide()
                }, onError: { error in
                    ProgressHelper.shared.hide()
                }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
}
