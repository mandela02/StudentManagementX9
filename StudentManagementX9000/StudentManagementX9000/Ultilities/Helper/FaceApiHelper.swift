//
//  FaceApiHelper.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/18/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation
import ProjectOxfordFace

struct FaceModel {
    var faceImage: UIImage?
    var gender: String?
    var emotion: String?
    var age: String?
    var rect: CGRect?
}

protocol FaceApiDelegate: class {
    func didFinishDetection(models: [FaceModel])
}

class FaceApiHelper {
    let client = MPOFaceServiceClient(endpointAndSubscriptionKey: FaceKey.endPoint, key: FaceKey.subscriptionKey)
    weak var delegate: FaceApiDelegate?

    func detectFace(image: UIImage) {
        var faceModels: [FaceModel] = []
        let jpegData = image.jpegData(compressionQuality: 0.75)

        client?.detect(with: jpegData,
                       returnFaceId: true,
                       returnFaceLandmarks: true,
                       returnFaceAttributes: [NSNumber(value: MPOFaceAttributeTypeGender.rawValue),
                                              NSNumber(value: MPOFaceAttributeTypeAge.rawValue),
                                              NSNumber(value: MPOFaceAttributeTypeEmotion.rawValue)],
                       completionBlock: { [weak self] faceCollection, error in
                        guard let self = self else {
                            return
                        }
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        guard let faceCollection = faceCollection else {
                            return
                        }
                        for face in faceCollection {
                            guard let faceRectangleLeft = face.faceRectangle.left,
                                let faceRectangleTop = face.faceRectangle.top,
                                let faceRectangleWidth = face.faceRectangle.width,
                                let faceRectangleHeight = face.faceRectangle.height else {
                                continue
                            }
                            let faceRect = CGRect(x: CGFloat(faceRectangleLeft.floatValue),
                                                  y: CGFloat(faceRectangleTop.floatValue),
                                                  width: CGFloat(faceRectangleWidth.floatValue),
                                                  height: CGFloat(faceRectangleHeight.floatValue))
                            let croppedImage = image.cgImage?.cropping(to: faceRect)
                            if let croppedImage = croppedImage {
                                let faceModel = FaceModel(faceImage: UIImage(cgImage: croppedImage),
                                                          gender: face.attributes.gender,
                                                          emotion: face.attributes?.emotion.mostEmotion,
                                                          age: face.attributes?.age.stringValue,
                                                          rect: faceRect)
                                faceModels.append(faceModel)
                            }
                        }
                        self.delegate?.didFinishDetection(models: faceModels)
        })
    }
}
