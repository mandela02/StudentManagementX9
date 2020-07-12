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

struct StorageImage {
    var name: String?
    var image: UIImage
    var isSelected: Bool = false
}

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

    static func getAvatar(from lib: String) -> Observable<UIImage> {
        return Observable.create { observer in
            storageRef.child(lib).listAll { results, error in
                if let error = error {
                    print("Error \(error)")
                    observer.onError(error)
                    observer.onCompleted()
                    return
                }
                guard let result = results.items.first else {
                    let errorTemp = NSError(domain: "nil image", code: 405, userInfo: nil)
                    observer.onError(errorTemp)
                    observer.onCompleted()
                    return
                }
                getImage(from: result).subscribe(onNext: { image in
                    guard let image = image else {
                        let errorTemp = NSError(domain: "nil image", code: 405, userInfo: nil)
                        observer.onError(errorTemp)
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(image)
                    observer.onCompleted()
                    }).disposed(by: disposeBag)
            }
            return Disposables.create()
        }
    }

    static func getAllImage(of lib: String) -> Observable<[StorageImage]> {
        return Observable.create { observer in
            var images: [StorageImage] = []
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
                        images.append(StorageImage(name: result.name, image: image))
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
                let error = NSError(domain: "Nil data", code: 01, userInfo: nil)
                observer.onError(error)
                observer.onCompleted()
                return Disposables.create()
            }
            let uniqueId = UUID().uuidString
            storageRef.child(lib).child(uniqueId + ".png").putData(uploadData, metadata: nil) { _, error in
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

    static func uploadMultiImage(of images: [UIImage], at lib: String) -> Observable<Void> {
        return Observable.create { observer in
            let dispatchGroup = DispatchGroup()
            for image in images {
                dispatchGroup.enter()
                guard let uploadData = image.pngData() else {
                    let error = NSError(domain: "Nil data", code: 01, userInfo: nil)
                    observer.onError(error)
                    continue
                }
                let uniqueId = UUID().uuidString
                storageRef.child(lib).child(uniqueId + ".png").putData(uploadData, metadata: nil) { _, error in
                    if let error = error {
                        observer.onError(error)
                        print("Error \(error)")
                        return
                    }
                    observer.onNext(())
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    static func deleteImage(with name: String, of lib: String) -> Observable<Bool> {
        return Observable.create { observer in
            storageRef.child(lib).child(name).delete { error in
                if let _ = error {
                    observer.onNext(false)
                    observer.onCompleted()
                } else {
                    observer.onNext(true)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
