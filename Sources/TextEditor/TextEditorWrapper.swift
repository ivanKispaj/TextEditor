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
    
    var isAddedObserver: Bool = false
    
    private(set) var attributedText: NSMutableAttributedString
    @Binding private var height: CGFloat
    private var controller: TextViewController
    private var textView: UITextView
    private var accessoryView: InputAccessoryView
    private let placeholder: String
    private let lineSpacing: CGFloat = 3
    // Default color
    private let hintColor = UIColor.label
    private var defaultFontSize: CGFloat = 24
    private let defaultFontName = "AvenirNext-Regular"
    let onCommit: ((NSAttributedString) -> Void)
    private var imageBorderWidth: CGFloat = 10
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
        onCommit: @escaping ((NSAttributedString) -> Void)
    ) {
        
        self.attributedText = attributedText
        self._height = height
        self.controller = TextViewController()
        self.textView = UITextView()
        self.placeholder = placeholder
        self.onCommit = onCommit
        self.accessoryView = InputAccessoryView(frame: .zero, inputViewStyle: .default, accessorySections: sections)
        
    }
    
    // makeUIView method
    func makeUIViewController(context: Context) -> some UIViewController {
        setUpTextView()
        let sections = accessoryView.accessorySections
        let rect = CGRect(x: 0, y: 0, width: self.controller.view.frame.width, height: sections.contains(.color) ? 80 : 50)
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
        controller.parentView = self
        return Coordinator(self)
    }
    
    func getAttributedtext() -> NSAttributedString {
        self.textView.attributedText
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
        textView.tintColor = self.hintColor
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
    
    
    //MARK: - Coordinator
    class Coordinator: NSObject, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TextEditorDelegate {
        var parent: TextEditorWrapper
        var fontName: String

        init(_ parent: TextEditorWrapper) {
            self.parent = parent
            self.fontName = parent.defaultFontName
        }
        
        // MARK: - Image Picker delegate method
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage, let image = img.roundedImageWithBorder(color: .systemGray5,borderWidth: parent.imageBorderWidth) {
                
                textViewDidBeginEditing(parent.textView)
                let newString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
                var rect: CGSize
                let width: CGFloat = parent.controller.view.frame.width
                if image.size.width <= width {
                    rect = CGSize(width: image.size.width, height: image.size.height)
                } else {
                    rect = getRectForAttachment(image: image, width: width)
                }
                
                let textAttachment = NSTextAttachment(image: image)
                textAttachment.bounds = CGRect(x: 0, y: 0, width: rect.width, height: rect.height)
                textAttachment.image?.withTintColor(.label)
                let attachmentString = NSAttributedString(attachment: textAttachment)
                
                let font = UIFont(name: parent.defaultFontName, size: TextStyleFormat.plainText.rawValue)!
                let color = UIColor.label
                var attr: [NSAttributedString.Key : Any] = [:]
                attr[.font] = font
                attr[.foregroundColor] = color
                
                newString.append(NSAttributedString(string: "\n"))
                let range = (newString.string as NSString).range(of: newString.string)
                newString.append(attachmentString)
                newString.append(NSAttributedString(string: "\n"))
                newString.addAttributes(attr, range: NSRange(location: range.length, length: 2))
                
                parent.textView.attributedText = newString
              
            }
            textViewDidChange(parent.textView)
            parent.textView.becomeFirstResponder()
            picker.dismiss(animated: true, completion: nil)
        }
        
        // calculates CGSize in by image proportions and screen size
        /// - parameter image: UIImage for which we calculate the size
        /// - parameter deviceSize: CGSize devices
        /// - returns:  image CGSize calculated in proportion to the screen size
        func getRectForAttachment(image: UIImage, width: CGFloat) -> CGSize {
            var newWidth = width
            newWidth -= parent.imageBorderWidth
            let ratio = image.size.width / width
            let imageH = image.size.height / ratio
            return CGSize(width: width, height: imageH)
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
            parent.textView.resignFirstResponder()
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = sourceType
            parent.controller.present(imagePicker, animated: true)
        }
        
        func hideKeyboard() {
            parent.textView.resignFirstResponder()
        }
        
        /// recalculating textview height
        private func recalculatingTextViewSize() {
           
            let size = CGSize(width: parent.controller.view.frame.width, height: .infinity)
            let estimatedSize = parent.textView.sizeThatFits(size)
            
            if parent.height != estimatedSize.height {
                DispatchQueue.main.async {
                    self.parent.height = estimatedSize.height
                }
            }
            parent.textView.scrollRangeToVisible(parent.textView.selectedRange)
        }
        
        // method for recalculating nstextattachmentcell bounds
        private func prepareNSAttachmentBound() {
           
            let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: parent.textView.attributedText)
            let width: CGFloat = parent.controller.view.frame.width
            
            text.enumerateAttribute(.attachment, in: NSRange(location: 0, length: text.length), options: [], using: { [width] (object, range, pointer) in
                if let attachment = object as? NSTextAttachment, let img = attachment.image { //(forBounds: parent.textView.bounds, textContainer: textViewAsAny as? NSTextContainer, characterIndex: range.location) {
                    let newSize = getRectForAttachment(image: img, width: width)
                    textViewDidBeginEditing(parent.textView)
                    let font = UIFont(name: parent.defaultFontName, size: TextStyleFormat.plainText.rawValue)!
                    let color = UIColor.label
                    var attr: [NSAttributedString.Key : Any] = [:]
                    attr[.font] = font
                    attr[.foregroundColor] = color
                    text.deleteCharacters(in: range)
                    
                    if img.size.width <= width {
                        attachment.bounds = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                    
                    } else {
                        attachment.bounds = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
                    
                    }
                    let attachmentString = NSAttributedString(attachment: attachment)
                    text.insert(attachmentString, at: range.location)
                    text.addAttributes(attr, range: range)
                    parent.textView.attributedText = text
                    textViewDidChange(parent.textView)

                    
                }
            })
            
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
            ///adding an observer to track the position of the screen
            if !parent.isAddedObserver {
                
                NotificationCenter.default.addObserver(self, selector: #selector(handleForChange), name: NSNotification.Name("willChangeViewSize"), object: nil)
                parent.isAddedObserver.toggle()
            }
            
            
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
                self.recalculatingTextViewSize()
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {

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
        
        
        @objc func handleForChange(_ notification: Notification) {
            if notification.userInfo?.values.first is CGSize {
                textViewDidEndEditing(parent.textView)
                  self.prepareNSAttachmentBound()
                
                
            }
        }
    }
}



@available(iOS 15.0, *)
class TextViewController: UIViewController {
    
    var parentView: TextEditorWrapper?
    private var newSize: CGSize  = CGSize(width: 0, height: 0) {
        didSet {
            if oldValue.width != newSize.width {
                
                NotificationCenter.default.post(name: NSNotification.Name("willChangeViewSize"),
                                    object: nil,
                                                userInfo: ["newSize": newSize])
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
         newSize = self.view.frame.size
        
   
    }
    override func viewDidDisappear(_ animated: Bool) {
        if var mainParent = parentView {
            NotificationCenter.default.removeObserver(self, name:  NSNotification.Name("willChangeViewSize"), object: nil)
            mainParent.isAddedObserver.toggle()
            mainParent.onCommit(mainParent.getAttributedtext())
        }
    }
}
