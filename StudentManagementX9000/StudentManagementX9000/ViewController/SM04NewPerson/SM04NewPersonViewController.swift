//
//  SM04NewPersonViewController.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/19/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SM04NewPersonViewController: BaseViewController {

    let reuseIdentifier = "NewPersonCell"

    @IBOutlet weak var studentNameTextField: UITextField!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var imageCollectionView: UICollectionView!

    let viewModel = SM04NewPersonViewModel()
    let disposeBag = DisposeBag()

    override func configureView() {
        configureCollectionView()
        FaceApiHelper.shared.delegate = self
    }

    override func configureObservers() {
        studentNameTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        viewModel.isNameValid.subscribe(onNext: { [weak self] isValid in
            guard let self = self else { return }
            self.saveButton.isEnabled = isValid
            self.pickImageButton.isEnabled = isValid
        }).disposed(by: disposeBag)
    }

    private func openImagePicker(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    @IBAction func pickImageButtonPressed(_ sender: Any) {
        if viewModel.student.value == nil {
            viewModel.createStudent().subscribe(onNext: {[weak self] _ in
                guard let self = self else { return }
                self.openImagePicker(source: .photoLibrary)
            }).disposed(by: disposeBag)
        } else {
            self.openImagePicker(source: .photoLibrary)
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        guard let student = viewModel.student.value else {
            return
        }
        // crash here
        FaceApiHelper.shared.updatePerson(with: viewModel.name.value, of: student)
    }

    private func configureCollectionView() {
        imageCollectionView.rx.setDelegate(self).disposed(by: disposeBag)
        let datasource = RxCollectionViewSectionedReloadDataSource<ImageSectionModel>(configureCell: { [weak self] (_, collectionView, indexPath, image) -> UICollectionViewCell in
            guard let self = self else { return UICollectionViewCell() }
            if let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier,
                                     for: indexPath) as? SM04NewPersionCollectionViewCell {
                cell.configureCell(with: image)
                return cell
            }
            return UICollectionViewCell()
        })

        viewModel.listImageSectionModel
            .bind(to: imageCollectionView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
    }
}

extension SM04NewPersonViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true, completion: nil)
        guard let student = viewModel.student.value else {
            return
        }

        FaceApiHelper.shared.detectFace(image: image)

        FaceApiHelper.shared
            .trainPerson(with: image,
                         studentId: student.personId)
            .subscribe(onNext: { result in
                switch result {
                case .success:
                    print("success")
                case .error:
                    print("error")
                case .moreThanOneFace:
                    print("moreThanOneFace")
                case .noFace:
                    print("noFace")
                }
            }).disposed(by: disposeBag)
    }
}

extension SM04NewPersonViewController: FaceApiDelegate {
    func didFinishDetection(models: [FaceModel]) {
        if let faceModel = models.first, let image = faceModel.faceImage {
            viewModel.addNewImage(image: image)
        }
    }
}

extension SM04NewPersonViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = CollectionView.sectionInsets.left
            + CollectionView.sectionInsets.right
            + (CollectionView.sectionInsets.left * (CollectionView.numberOfCellinRow - 1))
        let size = Int((UIScreen.main.bounds.width - padding - 40) / CollectionView.numberOfCellinRow)
        return CGSize(width: size, height: size/2)
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
