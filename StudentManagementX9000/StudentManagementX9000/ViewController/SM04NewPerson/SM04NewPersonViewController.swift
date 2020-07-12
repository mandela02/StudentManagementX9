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

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!

    let viewModel = SM04NewPersonViewModel()
    let disposeBag = DisposeBag()

    override func configureView() {
        configureCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if viewModel.mode.value == .update, let student = viewModel.student.value {
            studentNameTextField.text   = student.studentName
            studentNameTextField.sendActions(for: .valueChanged)
            idTextField.text            = student.studentId
            idTextField.sendActions(for: .valueChanged)
            mailTextField.text          = student.studentMail
            mailTextField.sendActions(for: .valueChanged)
            phoneTextField.text         = student.studentPhone
            phoneTextField.sendActions(for: .valueChanged)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.mode.value == .update {
            idTextField.isUserInteractionEnabled = false
        }
    }

    override func configureObservers() {
        studentNameTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.name)
            .disposed(by: disposeBag)
        idTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.id)
            .disposed(by: disposeBag)
        mailTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.mail)
            .disposed(by: disposeBag)
        phoneTextField.rx.text
            .map { $0 ?? "" }
            .bind(to: viewModel.phone)
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
        self.openActionSheet()
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
        createAndSave()
    }

    func createAndSave() {
        ProgressHelper.shared.show()
            StorageHelper.uploadMultiImage(of: viewModel.getAdditionImage(),
                                           at: viewModel.id.value)
                .subscribe(onError: { _ in
                    ProgressHelper.shared.hide()
                }, onCompleted: { [weak self] in
                    guard let self = self else { return }
                    self.viewModel.createStudentFaceModel().subscribe(onNext: { [weak self] person in
                        guard let self = self else { return }
                        guard let person = person else { return }
                        self.viewModel.trainPerson(of: person.personId) {
                            self.viewModel.createStudent {
                                self.save()
                            }
                        }
                    }).disposed(by: self.disposeBag)
                }).disposed(by: disposeBag)
    }

    private func save() {
        guard let studentFaceModel = viewModel.studentFacePerson.value else {
            ProgressHelper.shared.hide()
            return
        }
        FaceApiHelper.shared.updatePerson(with: self.viewModel.name.value,
                                          of: studentFaceModel)
            .subscribe(onNext: { () in
                ProgressHelper.shared.hide()
                self.navigationController?.popViewController(animated: true)
            }, onError: { _ in
                ProgressHelper.shared.hide()
            }).disposed(by: self.disposeBag)
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
                twoFaceViewController.image = image
                twoFaceViewController.newPersonParentViewController = self
                self.present(twoFaceViewController, animated: true, completion: nil)
            } else {
                guard let face = faces.first else { return }
                let croppedImage = FaceApiHelper.shared.cutImage(from: face, of: image)
                self.viewModel.addNewImage(image: ImageFace(image: image, face: face))
                self.viewModel.addCroppedImage(image: croppedImage)
                ProgressHelper.shared.hide()
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
