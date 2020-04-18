//
//  SM02PhotoViewController.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/18/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import UIKit

class SM02PhotoViewController: BaseViewController {

    @IBOutlet weak var openGalleryButton: UIButton!
    @IBOutlet weak var openCameraButton: UIButton!

    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var personListTableView: UITableView!

    override func configureView() {
        openCameraButton.setTitle("open Camera", for: .normal)
        openGalleryButton.setTitle("open Gallery", for: .normal)
        noImageLabel.text = "No Image Selected"
        noImageLabel.setBorder(color: .black, thickness: 1.0)
        personListTableView.setBorder(color: .black, thickness: 1.0)
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

extension SM02PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        noImageLabel.isHidden = true
        imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}
