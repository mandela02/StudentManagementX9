//
//  ImageHelper.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 10/8/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import Foundation
import UIKit

class ImageHelper {
    static func getImageFrom(url: URL, _ complete: @escaping ((UIImage?) -> Void)) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
           guard error == nil, let data = data else {
              complete(nil)
            return
           }
           DispatchQueue.main.async {
                complete(UIImage(data: data))
           }
        }).resume()
    }
}
