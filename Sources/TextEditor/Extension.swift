//
//  Extension.swift
//  Tasks
//
//  Created by Ivan Konishchev on 30.12.2022.
//

import SwiftUI

@available(iOS 13.0, *)
extension UIImage {
    func roundedImageWithBorder(color: UIColor, borderWidth: CGFloat) -> UIImage? {
        let borderWidth = borderWidth
        let cornerRadius:CGFloat = 2
        
        let rect = CGSize(width: size.width+borderWidth*1.5, height:size.height+borderWidth*1.8)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: rect))
        imageView.backgroundColor = color
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.cornerRadius = cornerRadius
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = borderWidth
        imageView.layer.borderColor = color.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension NSRange {
    var isEmpty: Bool {
        return self.upperBound == self.lowerBound
    }
}



