//
//  UIImage+Extension.swift
//  FinancialManagementX9000
//
//  Created by TriBQ on 9/16/19.
//  Copyright © 2019 Tribq. All rights reserved.
//

import UIKit

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    func drawRectangleOnImage(rect: CGRect) -> UIImage? {
        let imageSize = size
        let scale: CGFloat = 0
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let context = UIGraphicsGetCurrentContext()

        draw(at: CGPoint.zero)

        let path = CGPath(rect: rect, transform: nil)

        UIColor.red.setStroke()

        if let context = context {
            context.addPath(path)
            context.drawPath(using: .stroke)
        }

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
