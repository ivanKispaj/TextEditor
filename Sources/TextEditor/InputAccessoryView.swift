//
//  InputAccessoryView.swift
//  Tasks
//
//  Created by Ivan Konishchev on 30.12.2022.
//

import SwiftUI
import UIKit


@available(iOS 15.0, *)
final class InputAccessoryView: UIInputView {
        
    private var isShowHideColorButton: Bool = false
    private var stateTextFormat: SelecrtedTextFormat
    private var stateTextStyle: SelectedTextStyle
    private(set) var accessorySections: Array<EditorSection>
    private var textFontName: String = "AvenirNext-Regular"
    private let baseHeight: CGFloat = 44
    private let padding: CGFloat = 15
    private let buttonWidth: CGFloat = 45
    private let buttonHeight: CGFloat = 45
    private let cornerRadius: CGFloat = 6
    private let edgeInsets: CGFloat = 5
    private var selectedColor = UIColor(named: "whiteBlack") ?? UIColor.systemGray
    private let containerBackgroundColor: UIColor = .systemBackground
    private let colorConf = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    private var imageConf: UIImage.SymbolConfiguration {
        UIImage.SymbolConfiguration(pointSize: min(buttonWidth, buttonHeight) * 0.5)
    }
    
    weak var delegate: TextEditorDelegate!
    
    // MARK: Input Accessory separators
    
    private lazy var separator: UIView = {
        let separator = UIView()
        let spacerWidthConstraint = separator.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
        spacerWidthConstraint.priority = .defaultLow
        spacerWidthConstraint.isActive = true
        return separator
    }()
    
    
    // MARK: Input Accessory Buttons
    private lazy var keyboardHideButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "keyboard.chevron.compact.down", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(hideKeyboard(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.widthAnchor.constraint(equalToConstant: buttonWidth*1.5).isActive = true
        button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        
        return button
    }()
    
    // Button to select : bold, italics, underlined, strikethrough
    private lazy var fontFormatButton: UIButton = {
        
        let menu = setUpMenuFontFormat()
        let button = UIButton()
        button.showsMenuAsPrimaryAction = true
        button.menu = menu
        button.setImage(UIImage(systemName: "bold.italic.underline", withConfiguration: imageConf), for: .normal)
        button.backgroundColor = .clear
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1 / 1).isActive = true
        
        return button
    }()
    
    
    private lazy var textStyleButton: UIButton = {
        let menu = setUpTextStyleFormat()
        let button = UIButton()
        button.showsMenuAsPrimaryAction = true
        button.menu = menu
        button.setImage(UIImage(systemName: "textformat.size", withConfiguration: imageConf), for: .normal)
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1 / 1).isActive = true
        return button
    }()
    
    private lazy var textFontLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "\(Int(UIFont.systemFontSize))"
        
        return label
    }()
    
    
    
    var textAlignment: NSTextAlignment = .left {
        didSet {
            alignmentButton.setImage(UIImage(systemName: self.textAlignment.imageName, withConfiguration: imageConf), for: .normal)
        }
    }
    
    private lazy var alignmentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: NSTextAlignment.left.imageName, withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(alignText(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1 / 1).isActive = true
        
        return button
    }()
    
    private lazy var insertImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(insertImage(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1 / 1).isActive = true
        
        return button
    }()
    
    private lazy var fontSelectionButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "textformat.size", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(showFontPalette(_:)), for: .touchUpInside)
        button.backgroundColor = .clear
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1 / 1).isActive = true
        
        return button
    }()
    
    // MARK: Addtional Bars
    
    private let textColors: [UIColor] = [
        UIColor.label,
        UIColor.systemRed,
        UIColor.systemBlue,
        UIColor.systemCyan,
        UIColor.systemGray,
        UIColor.systemMint,
        UIColor.systemYellow,
        UIColor.systemBrown
        
    ]
    
    
    private lazy var showHideColorPalete: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paintpalette", withConfiguration: imageConf), for: .normal)
        button.addTarget(self, action: #selector(showHideColorPalete(_:)), for: .touchUpInside)
        button.tintColor = self.selectedColor
        button.backgroundColor = .clear
        button.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1 / 1).isActive = true
        return button
    }()
    
    
    private lazy var colorButtons: [UIButton] = {
        var buttons: [UIButton] = []
        
        for color in textColors {
            let button = UIButton()
            button.setImage(UIImage(systemName: "circle.fill", withConfiguration: colorConf), for: .normal)
            button.tintColor = color
            button.addTarget(self, action: #selector(showHideColorPalete(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        return buttons
    }()
    
    private lazy var colorPaletteBar: UIStackView = {
        let containerView = UIStackView(arrangedSubviews: colorButtons)
        containerView.axis = .horizontal
        containerView.alignment = .center
        containerView.spacing = padding/2
        containerView.isHidden = true
        containerView.distribution = .equalCentering
        return containerView
    }()
    
    // TODO: Support Fonts Selection
    private lazy var fontPaletteBar: UIStackView = {
        let containerView = UIStackView()
        return containerView
    }()
    
    // MARK: - Initialization
    
    private var accessoryContentView: UIStackView
    
    init(frame: CGRect, inputViewStyle: UIInputView.Style, accessorySections: Array<EditorSection>) {
        self.accessoryContentView = UIStackView()
        self.accessorySections = accessorySections
        self.stateTextFormat = SelecrtedTextFormat()
        self.stateTextStyle = SelectedTextStyle()
        super.init(frame: frame, inputViewStyle: inputViewStyle)
        
        setupAccessoryView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAccessoryView() {
        accessoryContentView.addArrangedSubview(toolbar)
        if accessorySections.contains(.color) {
            accessoryContentView.addArrangedSubview(colorPaletteBar)
        }
        
        accessoryContentView.axis = .vertical
        accessoryContentView.alignment = .leading
        accessoryContentView.distribution = .fillProportionally
        
        addSubview(accessoryContentView)
        backgroundColor = .secondarySystemBackground
        accessoryContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            accessoryContentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
            accessoryContentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
            accessoryContentView.topAnchor.constraint(equalTo: self.topAnchor),
            accessoryContentView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    // MARK: - Toolbar
    private var toolbar: UIStackView {
        let stackView = UIStackView()
        
        if accessorySections.contains(.fontFormat) {
            stackView.addArrangedSubview(fontFormatButton)
        }
        if accessorySections.contains(.fontStyle) {
            stackView.addArrangedSubview(textStyleButton)
        }
        
        if accessorySections.contains(.textAlignment) {
            stackView.addArrangedSubview(alignmentButton)
        }
        
        if accessorySections.contains(.image) {
            stackView.addArrangedSubview(insertImageButton)
        }
        
        if accessorySections.contains(.colorPalete) {
            stackView.addArrangedSubview(showHideColorPalete)
        }
        
        stackView.addArrangedSubview(separator)
        
        if accessorySections.contains(.keyboard) {
            stackView.addArrangedSubview(keyboardHideButton)
        }
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = padding
        stackView.distribution = .equalCentering
        
        return stackView
    }
    
    // Menu to choose from: large header, header, small header and plain text
    private func setUpTextStyleFormat() -> UIMenu {
        
        let menu = UIMenu(options: .displayInline, children: [
            UIDeferredMenuElement.uncached { [weak self] comletion in
                let action = [
                    UIAction(title: "Large header", state: self?.stateTextStyle.largeHeader ?? UIAction.State.off) { [weak self] action in
                        if self?.stateTextStyle.largeHeader == .off {
                            self?.stateTextStyle.largeHeader = .on
                            
                        } else {
                            self?.stateTextStyle.largeHeader = .off
                        }
                        self?.delegate.textStyle(self?.stateTextStyle.textStyle ?? .largeHeader)
                    },
                    
                    UIAction(title: "Header", state: self?.stateTextStyle.header ?? UIAction.State.off) { [weak self] action in
                        if self?.stateTextStyle.header == .off {
                            self?.stateTextStyle.header = .on
                            
                        } else {
                            self?.stateTextStyle.header = .off
                        }
                        self?.delegate.textStyle(self?.stateTextStyle.textStyle ?? .largeHeader)
                        
                    },
                    
                    UIAction(title: "Small header", state: self?.stateTextStyle.smallHeader ?? UIAction.State.off) { [weak self] action in
                        if self?.stateTextStyle.smallHeader == .off {
                            self?.stateTextStyle.smallHeader = .on
                            
                        } else {
                            self?.stateTextStyle.smallHeader = .off
                        }
                        self?.delegate.textStyle(self?.stateTextStyle.textStyle ?? .largeHeader)
                        
                    },
                    
                    UIAction(title: "Plain text", state: self?.stateTextStyle.plainText ?? UIAction.State.off) { [weak self] action in
                        if self?.stateTextStyle.plainText == .off {
                            self?.stateTextStyle.plainText = .on
                            
                        } else {
                            self?.stateTextStyle.plainText = .off
                        }
                        self?.delegate.textStyle(self?.stateTextStyle.textStyle ?? .largeHeader)
                        
                    },
                    
                ]
                comletion(action)
            }
        ])
        
        return menu
    }
    
    // Menu to choose from: bold, italic, underline and Strikethrough text
    private func setUpMenuFontFormat() -> UIMenu {
        let menu = UIMenu(options: .displayInline, children: [
            UIDeferredMenuElement.uncached { [weak self] completion in
                let actions = [
                    UIAction(title: "Underline",  image: UIImage(systemName: "underline"), state: self?.stateTextFormat.underline ?? UIAction.State.off) { [weak self] action in
                        if self?.stateTextFormat.underline == .off {
                            self?.stateTextFormat.underline = .on
                            
                        } else {
                            self?.stateTextFormat.underline = .off
                        }
                        self?.delegate.textUnderline()
                    },
                    UIAction(title: "Strikethrough", image: UIImage(systemName: "strikethrough"), state: self?.stateTextFormat.strikethrough ?? UIAction.State.off) { [weak self] action in
                        if self?.stateTextFormat.strikethrough == .off {
                            self?.stateTextFormat.strikethrough = .on
                            
                        } else {
                            self?.stateTextFormat.strikethrough = .off
                        }
                        self?.delegate.textStrike()
                    },
                    UIAction(title: "Italic", image: UIImage(systemName: "italic"), state: self?.stateTextFormat.italic ?? UIAction.State.off) {[weak self] action in
                        if self?.stateTextFormat.italic == .off {
                            self?.stateTextFormat.italic = .on
                            
                            
                        } else {
                            self?.stateTextFormat.italic = .off
                        }
                        self?.delegate.textItalic()
                    },
                    UIAction( title: "Bold", image: UIImage(systemName: "bold"),state: self?.stateTextFormat.bold ?? UIAction.State.off) { [weak self] action in
                        if self?.stateTextFormat.bold == .off {
                            self?.stateTextFormat.bold = .on
                            
                            
                        } else {
                            self?.stateTextFormat.bold = .off
                        }
                        self?.delegate.textBold()
                    }
                ]
                completion(actions)
            }
        ])
        
        return menu
    }
    
    // MARK: - Button Actions
    
 
    @objc private func showHideColorPalete(_ button: UIButton) {
        if self.isShowHideColorButton {
            self.selectedColor = button.tintColor
            self.showHideColorPalete.tintColor = button.tintColor
            delegate.textColor(color: button.tintColor)
        }
        self.isShowHideColorButton.toggle()
        self.colorPaletteBar.isHidden.toggle()
    }
    
    @objc private func showFontPalette(_ button: UIButton) {
        //
    }
    
    @objc private func hideKeyboard(_ button: UIButton) {
        delegate.hideKeyboard()
    }
    
    @objc private func textStyle(_ button: UIButton) {
        if button.tag == 1 {
            delegate.textBold()
        } else if button.tag == 2 {
            delegate.textItalic()
        } else if button.tag == 3 {
            delegate.textUnderline()
        } else if button.tag == 4 {
            delegate.textStrike()
        }
    }
    
    @objc private func alignText(_ button: UIButton) {
        switch textAlignment {
        case .left: textAlignment = .center
        case .center: textAlignment = .right
        case .right: textAlignment = .left
        case .justified: textAlignment = .justified
        case .natural: textAlignment = .natural
        @unknown default: textAlignment = .left
        }
        delegate.textAlign(align: textAlignment)
    }
    
    @objc private func textFont(font: String) {
        delegate.textFont(name: font)
    }
    
    @objc private func insertImage(_ button: UIButton) {
        delegate.insertImage()
    }
    
    private func selectedButton(_ button: UIButton, isSelected: Bool) {
        button.layer.cornerRadius = isSelected ? cornerRadius : 0
        button.layer.backgroundColor = isSelected ? selectedColor.cgColor : UIColor.clear.cgColor
    }
    
    func updateToolbar(typingAttributes: [NSAttributedString.Key : Any], textAlignment: NSTextAlignment) {
        alignmentButton.setImage(UIImage(systemName: textAlignment.imageName, withConfiguration: imageConf), for: .normal)
        
        for attribute in typingAttributes {
            if attribute.key == .font {
                if let font = attribute.value as? UIFont {
                    let fontSize = font.pointSize
                    switch fontSize {
                    case TextStyleFormat.plainText.rawValue:
                        self.stateTextStyle.plainText = .on
                    case TextStyleFormat.smallHeader.rawValue:
                        self.stateTextStyle.smallHeader = .on
                    case TextStyleFormat.header.rawValue:
                        self.stateTextStyle.header = .on
                    case TextStyleFormat.largeHeader.rawValue:
                        self.stateTextStyle.largeHeader = .on
                    default:
                        self.stateTextStyle.largeHeader = .on
                        self.stateTextStyle.largeHeader = .off
                    }
                    textFontLabel.text = "\(Int(fontSize))"
                    let isBold = (font == UIFont.boldSystemFont(ofSize: fontSize))
                    let isItalic = (font == UIFont.italicSystemFont(ofSize: fontSize))
                    
                    isBold ? (self.stateTextFormat.bold = .on) : (self.stateTextFormat.bold = .off)
                    isItalic ? (self.stateTextFormat.italic = .on) : (self.stateTextFormat.italic = .off)
                } else {
                    self.stateTextFormat.bold = .off
                    self.stateTextFormat.italic = .off
                    
                }
            }
            
            if attribute.key == .underlineStyle {
                if let style = attribute.value as? Int {
                    style == NSUnderlineStyle.single.rawValue ? (self.stateTextFormat.underline = .on) : (self.stateTextFormat.underline = .off)
                } else {
                    self.stateTextFormat.underline = .off
                }
            }
            
            if attribute.key == .strikethroughStyle {
                if let style = attribute.value as? Int {
                    style == NSUnderlineStyle.single.rawValue ? (self.stateTextFormat.strikethrough = .on) : (self.stateTextFormat.strikethrough = .off)
                }  else {
                    self.stateTextFormat.strikethrough = .off
                }
            }
            
            if attribute.key == .foregroundColor {
                var textColor = textColors.first!
                if let color = attribute.value as? UIColor {
                    textColor = color
                    self.selectedColor = color
                    self.showHideColorPalete.tintColor = color
                }
                for button in colorButtons {
                    if button.tintColor == textColor {
                        button.setImage(UIImage(systemName: "checkmark.circle.fill", withConfiguration: colorConf), for: .normal)
                    } else {
                        button.setImage(UIImage(systemName: "circle.fill", withConfiguration: colorConf), for: .normal)
                    }
                }
            }
        }
    }
}
