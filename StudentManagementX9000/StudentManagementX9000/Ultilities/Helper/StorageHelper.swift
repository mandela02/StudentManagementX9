//
//  StorageHelper.swift
//  StudentManagementX9000
//
//  Created by Bui Quang Tri on 4/28/20.
//  Copyright © 2020 Bui Quang Tri. All rights reserved.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa
import UIKit

class StorageHelper {
    private static let storage = Storage.storage()
    private static var storageRef: StorageReference {
        return storage.reference()
    }
    private static let disposeBag = DisposeBag()

    static func getImage(from ref: StorageReference) -> Observable<UIImage?> {
        return Observable.create { observer in
            ref.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error \(error)")
                    observer.onError(error)
                    observer.onCompleted()
                } else {
                    guard let data = data, let image = UIImage(data: data) else {
                        observer.onNext(nil)
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(image)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    static func getAllImage(of lib: String) -> Observable<[UIImage]> {
        return Observable.create { observer in
            var images: [UIImage] = []
            storageRef.child(lib).listAll { results, error in
                if let error = error {
                    print("Error \(error)")
                    observer.onError(error)
                    observer.onCompleted()
                    return
                }
                for result in results.items {
                    getImage(from: result).subscribe(onNext: { image in
                        guard let image = image else {
                            return
                        }
                        images.append(image)
                        observer.onNext(images)
                        }).disposed(by: disposeBag)
                }
                //observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func uploadImage(of image: UIImage, at lib: String) -> Observable<Void> {
        return Observable.create { observer in
            guard let uploadData = image.pngData() else {
                observer.onCompleted()
                return Disposables.create()
            }
            storageRef.child(lib).putData(uploadData, metadata: nil) { metadata, error in
                if let error = error {
                    observer.onError(error)
                    observer.onCompleted()
                    print("Error \(error)")
                    return
                }
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
