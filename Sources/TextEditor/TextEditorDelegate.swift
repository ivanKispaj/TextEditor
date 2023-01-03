//
//  TextEditorDelegate.swift
//  Tasks
//
//  Created by Ivan Konishchev on 30.12.2022.
//

import SwiftUI

protocol TextEditorDelegate: AnyObject {
    // Font
    func textStyle(_ textStyle: TextStyleFormat)
    func textBold()
    func textItalic()
    func textStrike()
    func textUnderline()
    func textColor(color: UIColor)
    func textFont(name: String)
    func insertImage()
    func textAlign(align: NSTextAlignment)
    func hideKeyboard()
}

extension NSTextAlignment {
    var imageName: String {
        switch self {
        case .left: return "text.alignleft"
        case .center: return "text.aligncenter"
        case .right: return "text.alignright"
        case .justified: return "text.justify"
        case .natural: return "text.aligncenter"
        @unknown default: return "text.aligncenter"
        }
    }
    
    static let available: [NSTextAlignment] = [.left, .right, .center]
}
