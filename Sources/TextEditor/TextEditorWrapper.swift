//
//  TextEditorWrapper.swift
//  Tasks
//
//  Created by Ivan Konishchev on 30.12.2022.
//

import SwiftUI
import UIKit

@available(iOS 15.0, *)
struct TextEditorWrapper: UIViewControllerRepresentable {
    
    
    private var deviceFrame: CGRect
    private var attributedText: NSMutableAttributedString
    @Binding private var height: CGFloat
    private var controller: UIViewController
    private var textView: UITextView
    private var accessoryView: InputAccessoryView
    private let placeholder: String
    private let lineSpacing: CGFloat = 3
    // Default color
    private let hintColor = UIColor(named: "whiteBlack") ?? UIColor.systemGray6
    private var defaultFontSize: CGFloat = 24
    private let defaultFontName = "AvenirNext-Regular"
    private let onCommit: ((NSAttributedString) -> Void)
    private var isImagePicker: Bool = false
    private var isHeader: Bool = false
    private var defaultFont: UIFont {
        return UIFont(name: defaultFontName, size: defaultFontSize) ?? .systemFont(ofSize: defaultFontSize)
    }
    
    // MARK: - Init
    init(
        
        attributedText: NSMutableAttributedString,
        height: Binding<CGFloat>,
        placeholder: String,
        sections: Array<EditorSection>,
        deviceFrame: CGRect,
        onCommit: @escaping ((NSAttributedString) -> Void)
    ) {
        
        self.attributedText = attributedText
        self._height = height
        self.controller = UIViewController()
        self.textView = UITextView()
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.deviceFrame = deviceFrame
        self.accessoryView = InputAccessoryView(frame: .zero, inputViewStyle: .default, accessorySections: sections)
    }
    
    // makeUIView method
    func makeUIViewController(context: Context) -> some UIViewController {
        setUpTextView()
        let sections = accessoryView.accessorySections
        let rect = CGRect(x: 0, y: 0, width: deviceFrame.width, height: sections.contains(.color) ? 80 : 50)
        self.accessoryView.frame = rect
        textView.delegate = context.coordinator
        context.coordinator.textViewDidChange(textView)
        
        accessoryView.delegate = context.coordinator
        textView.inputAccessoryView = accessoryView
        return controller
    }
    
    // updateUIViewController method
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    // makeCoordinator method
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    //MARK: - The first TextView setup
    private func setUpTextView() {
        // If this is the first creation of an empty TextView
        // Setting the default font attributes
        if attributedText.string == "" {
            textView.attributedText = NSAttributedString(string: placeholder, attributes: [.foregroundColor: hintColor])
            let headerFont = UIFont(name: defaultFontName, size: defaultFontSize) ?? .systemFont(ofSize: defaultFontSize)
            textView.typingAttributes = [.font : headerFont]
        } else {
            // Otherwise, text with attributes is written to TextView
            textView.attributedText = attributedText
        }
        textView.isEditable = true
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = true
        textView.textAlignment = .left
        textView.becomeFirstResponder()
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.backgroundColor = .systemBackground
        
        controller.view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor),
            textView.widthAnchor.constraint(equalTo: controller.view.widthAnchor),
        ])
        
        
    }
    
    
    
    private func scaleImage(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
        let ratio = image.size.width / image.size.height
        let imageW: CGFloat = (ratio >= 1) ? maxWidth : image.size.width*(maxHeight/image.size.height)
        let imageH: CGFloat = (ratio <= 1) ? maxHeight : image.size.height*(maxWidth/image.size.width)
        UIGraphicsBeginImageContext(CGSize(width: imageW, height: imageH))
        image.draw(in: CGRect(x: 0, y: 0, width: imageW, height: imageH))
        let scaledimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledimage!
    }
    
    //MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TextEditorDelegate {
        var parent: TextEditorWrapper
        var fontName: String
        
        private var isBold = false
        private var isItalic = false
        
        init(_ parent: TextEditorWrapper) {
            self.parent = parent
            self.fontName = parent.defaultFontName
            
        }
        
        // MARK: - Image Picker
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, var image = img.roundedImageWithBorder(color: .secondarySystemBackground) {
                textViewDidBeginEditing(parent.textView)
                let newString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
                image = scaleImage(image: image, maxWidth: 180, maxHeight: 180)
                
                let textAttachment = NSTextAttachment(image: image)
                let attachmentString = NSAttributedString(attachment: textAttachment)
                newString.append(attachmentString)
                parent.textView.attributedText = newString
                textViewDidChange(parent.textView)
            }
            parent.isImagePicker = false
            picker.dismiss(animated: true, completion: nil)
        }
        
        func scaleImage(image: UIImage, maxWidth: CGFloat, maxHeight: CGFloat) -> UIImage {
            let ratio = image.size.width / image.size.height
            let imageW: CGFloat = (ratio >= 1) ? maxWidth : image.size.width*(maxHeight/image.size.height)
            let imageH: CGFloat = (ratio <= 1) ? maxHeight : image.size.height*(maxWidth/image.size.width)
            UIGraphicsBeginImageContext(CGSize(width: imageW, height: imageH))
            image.draw(in: CGRect(x: 0, y: 0, width: imageW, height: imageH))
            let scaledimage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return scaledimage!
        }
        
        // MARK: - Text Editor Delegate
        
        func textBold() {
            let attributes = parent.textView.selectedRange.isEmpty ? parent.textView.typingAttributes : selectedAttributes
            let fontSize = getFontSize(attributes: attributes)
            
            let defaultFont = UIFont.systemFont(ofSize: fontSize)
            textEffect(type: UIFont.self, key: .font, value: UIFont.boldSystemFont(ofSize: fontSize), defaultValue: defaultFont)
        }
        
        func textUnderline() {
            textEffect(type: Int.self, key: .underlineStyle, value: NSUnderlineStyle.single.rawValue, defaultValue: .zero)
        }
        
        func textItalic() {
            let attributes = parent.textView.selectedRange.isEmpty ? parent.textView.typingAttributes : selectedAttributes
            let fontSize = getFontSize(attributes: attributes)
            
            let defaultFont = UIFont.systemFont(ofSize: fontSize)
            textEffect(type: UIFont.self, key: .font, value: UIFont.italicSystemFont(ofSize: fontSize), defaultValue: defaultFont)
        }
        
        func textStrike() {
            textEffect(type: Int.self, key: .strikethroughStyle, value: NSUnderlineStyle.single.rawValue, defaultValue: .zero)
        }
        
        func textAlign(align: NSTextAlignment) {
            parent.textView.textAlignment = align
        }
        
        func textStyle(_ textStyle: TextStyleFormat) {
            var font: UIFont
            let attributes = parent.textView.selectedRange.isEmpty ? parent.textView.typingAttributes : selectedAttributes
            
            let fontSize = textStyle.rawValue
            
            let defaultFont = UIFont.systemFont(ofSize: fontSize)
            if isContainBoldFont(attributes: attributes) {
                font = UIFont.boldSystemFont(ofSize: fontSize)
            } else if isContainItalicFont(attributes: attributes) {
                font = UIFont.italicSystemFont(ofSize: fontSize)
            } else {
                font = defaultFont
            }
            textEffect(type: UIFont.self, key: .font, value: font, defaultValue: defaultFont)
        }
        
        func textFont(name: String) {
            let attributes = parent.textView.selectedRange.isEmpty ? parent.textView.typingAttributes : selectedAttributes
            let fontSize = getFontSize(attributes: attributes)
            
            fontName = name
            let defaultFont = UIFont.systemFont(ofSize: fontSize)
            let newFont = UIFont(name: fontName, size: fontSize) ?? defaultFont
            textEffect(type: UIFont.self, key: .font, value: newFont, defaultValue: defaultFont)
        }
        
        func textColor(color: UIColor) {
            textEffect(type: UIColor.self, key: .foregroundColor, value: color, defaultValue: color)
        }
        
        func insertImage() {
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourceType
            parent.isImagePicker = true
            parent.controller.navigationController?.present(imagePicker, animated: true)
          //  parent.controller.present(imagePicker, animated: true, completion: nil)
        }
        
        func hideKeyboard() {
            parent.textView.resignFirstResponder()
        }
        
        // Add text attributes to text view
        private func textEffect<T: Equatable>(type: T.Type, key: NSAttributedString.Key, value: Any, defaultValue: T) {
            let range = parent.textView.selectedRange
            if !range.isEmpty {
                let isContain = isContain(type: type, range: range, key: key, value: value)
                let mutableString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
                if isContain {
                    mutableString.removeAttribute(key, range: range)
                    if key == .font {
                        mutableString.addAttributes([key : defaultValue], range: range)
                    }
                } else {
                    mutableString.addAttributes([key : value], range: range)
                }
                parent.textView.attributedText = mutableString
            } else {
                if let current = parent.textView.typingAttributes[key], current as! T == value as! T {
                    parent.textView.typingAttributes[key] = defaultValue
                } else {
                    parent.textView.typingAttributes[key] = value
                }
                parent.accessoryView.updateToolbar(typingAttributes: parent.textView.typingAttributes, textAlignment: parent.textView.textAlignment)
            }
        }
        
        // Find specific attribute in the range of text which user selected
        /// - parameter range: Selected range in text view
        private func isContain<T: Equatable>(type: T.Type, range: NSRange, key: NSAttributedString.Key, value: Any) -> Bool {
            var isContain: Bool = false
            parent.textView.attributedText.enumerateAttributes(in: range) { attributes, range, stop in
                if attributes.filter({ $0.key == key }).contains(where: {
                    $0.value as! T == value as! T
                }) {
                    isContain = true
                    stop.pointee = true
                }
            }
            return isContain
        }
        
        private func isContainBoldFont(attributes: [NSAttributedString.Key : Any]) -> Bool {
            return attributes.contains { attribute in
                if attribute.key == .font, let value = attribute.value as? UIFont {
                    return value == UIFont.boldSystemFont(ofSize: value.pointSize)
                } else {
                    return false
                }
            }
        }
        
        private func isContainItalicFont(attributes: [NSAttributedString.Key : Any]) -> Bool {
            return attributes.contains { attribute in
                if attribute.key == .font, let value = attribute.value as? UIFont {
                    return value == UIFont.italicSystemFont(ofSize: value.pointSize)
                } else {
                    return false
                }
            }
        }
        
        /// Checks if the line after the very first header is empty
        private func isEmptyLineAfterHeader(_ textView: UITextView) -> Bool {
            let textArr = textView.attributedText.string.components(separatedBy: "\n")
            
            if  textArr.count == 2 && textArr[1].isEmpty {
                return true
            }
            return false
        }
        
        // Gets the font size
        /// - parameter attributes: Attribute Dictionary array
        /// - Returns: the size of the text in CGFloat forma
        private func getFontSize(attributes: [NSAttributedString.Key : Any]) -> CGFloat {
            if let value = attributes[.font] as? UIFont {
                return value.pointSize
            } else {
                return UIFont.systemFontSize
            }
        }
        
        // List of selected attributes for the text
        var selectedAttributes: [NSAttributedString.Key : Any] {
            let textRange = parent.textView.selectedRange
            if textRange.isEmpty {
                return [:]
            } else {
                var textAttributes: [NSAttributedString.Key : Any] = [:]
                parent.textView.attributedText.enumerateAttributes(in: textRange) { attributes, range, stop in
                    for item in attributes {
                        textAttributes[item.key] = item.value
                    }
                }
                return textAttributes
            }
        }
        
        
        // MARK: - Text View Delegate
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            let textRange = parent.textView.selectedRange
            
            if textRange.isEmpty {
                parent.accessoryView.updateToolbar(typingAttributes: parent.textView.typingAttributes, textAlignment: parent.textView.textAlignment)
            } else {
                parent.accessoryView.updateToolbar(typingAttributes: selectedAttributes, textAlignment: parent.textView.textAlignment)
            }
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            
            if textView.attributedText.string == parent.placeholder {
                parent.isHeader.toggle()
                /// We get here when the first creation and the field contains nothing!
                self.textStyle(.largeHeader)
                self.textColor(color: parent.hintColor)
            } else {
                /// If the line after the header is empty,
                /// resetting the font size value to the smallest
                if isEmptyLineAfterHeader(textView){
                    self.textStyle(.plainText)
                }
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            
            if !parent.isImagePicker {
                parent.onCommit(textView.attributedText)
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            
            if textView.attributedText.string != parent.placeholder {
                parent.attributedText = NSMutableAttributedString(attributedString: textView.attributedText)
            }
            /// If the line after the header is empty,
            /// resetting the font size value to the smallest
            if  isEmptyLineAfterHeader(textView) {
                self.textStyle(.plainText)
                parent.isHeader = false
            }
            let size = CGSize(width: parent.controller.view.frame.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            if parent.height != estimatedSize.height {
                DispatchQueue.main.async {
                    self.parent.height = estimatedSize.height
                }
            }
            textView.scrollRangeToVisible(textView.selectedRange)
        }
        
        
        
    }
    
}

