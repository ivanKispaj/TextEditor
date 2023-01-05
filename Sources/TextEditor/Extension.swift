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

extension UIColor {
    
    public enum CollorName: String {
        case whiteBlack = "whiteBlack"

    }
    
    private static var colorCash: [CollorName : UIColor] = [:]
    
    public static func appColor(_ name: CollorName) -> UIColor {
        if let cashedColor = colorCash[name] {
            return cashedColor
        }
        self.clearColorCashIfNeeded()
        let color: UIColor
        
        if let bundle = Bundle(path: "/Assets"),
            let uiColor =  UIColor(named: name.rawValue, in: bundle, compatibleWith: nil) {
            color = uiColor
        } else {
            color = .black
        }
        
        colorCash[name] = color
        return color
    }
    
    private static func clearColorCashIfNeeded() {
        let maxObjectCount = 100
        guard self.colorCash.count >= maxObjectCount else { return }
        self.colorCash = [:]
    }
}

