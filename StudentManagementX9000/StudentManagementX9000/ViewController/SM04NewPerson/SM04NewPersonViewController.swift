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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.mode.value == .update, let student = viewModel.student.value {
            studentNameTextField.text = student.name
            viewModel.name.accept(student.name)
        }
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
                self.openActionSheet()
            }).disposed(by: disposeBag)
        } else {
            self.openActionSheet()
        }
    }

    private func openActionSheet() {
        let preferredStyle = UIAlertController.Style.actionSheet
        let alertController = UIAlertController(title: title,
                                            message: "Choose Option",
                                            preferredStyle: preferredStyle)

        let cameraAction = UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.openImagePicker(source: .camera)
        })
        alertController.addAction(cameraAction)

        let libraryAciton = UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.openImagePicker(source: .photoLibrary)
        })
        alertController.addAction(libraryAciton)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        save()
    }

    private func save() {
        ProgressHelper.shared.show()
        guard let student = viewModel.student.value else {
            ProgressHelper.shared.hide()
            return
        }
        StorageHelper.uploadMultiImage(of: viewModel.getAdditionImage(),
                                       at: student.personId)
            .subscribe(onError: { _ in
                ProgressHelper.shared.hide()
            }, onCompleted: { [weak self] in
                guard let self = self else { return }
                FaceApiHelper.shared.updatePerson(with: self.viewModel.name.value,
                                                  of: student)
                    .subscribe(onNext: { () in
                        ProgressHelper.shared.hide()
                        self.navigationController?.popViewController(animated: true)
                    }, onError: { error in
                        ProgressHelper.shared.hide()
                    }).disposed(by: self.disposeBag)
            }).disposed(by: disposeBag)
    }

    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        imageCollectionView.collectionViewLayout = layout

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
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true, completion: nil)
        guard let student = viewModel.student.value else {
            return
        }
        ProgressHelper.shared.show()
        FaceApiHelper.shared.detect(image: image).subscribe(onNext: { [weak self] faces in
            guard let self = self else { return }
            guard let faces = faces else {
                return
            }
            if faces.count == 0 {
                ProgressHelper.shared.hide()
            } else if faces.count != 1 {
                ProgressHelper.shared.hide()
                var imageList: [UIImage] = []
                for face in faces {
                    imageList.append(FaceApiHelper.shared.cutImage(from: face, of: image))
                }
                let twoFaceViewController = SM05TwoFaceViewController.instantiateFromStoryboard()
                twoFaceViewController.modalPresentationStyle = .overFullScreen
                twoFaceViewController.modalTransitionStyle = .crossDissolve
                twoFaceViewController.faces = faces
                twoFaceViewController.studentId = student.personId
                twoFaceViewController.image = image
                twoFaceViewController.newPersonParentViewController = self
                self.present(twoFaceViewController, animated: true, completion: nil)
            } else {
                guard let face = faces.first else { return }
                self.viewModel.addNewImage(image: FaceApiHelper.shared.cutImage(from: face, of: image))
                FaceApiHelper.shared.trainPerson(image: image ,
                                                 with: face,
                                                 studentId: student.personId).subscribe(onNext: { _ in
                                                    ProgressHelper.shared.hide()
                                                 }, onError: { _ in
                                                    ProgressHelper.shared.hide()
                                                 }).disposed(by: self.disposeBag)
            }
            }, onError: { _ in
                ProgressHelper.shared.hide()
        }).disposed(by: disposeBag)
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
