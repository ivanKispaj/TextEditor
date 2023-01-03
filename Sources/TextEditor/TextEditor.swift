//
//  TextEditor.swift
//  Tasks
//
//  Created by Ivan Konishchev on 30.12.2022.
//

import SwiftUI

@available(iOS 15.0, *)
public struct TextEditor: View {
    private var deviceFrame: CGRect
    @State var dynamicHeight: CGFloat = 100
    private let attributedText: NSMutableAttributedString
    private let placeholder: String
    private let accessorySections: Array<EditorSection>
    private let onCommit: (NSAttributedString) -> Void
    public init(
        attributedText: NSMutableAttributedString,
        placeholder: String = "",
        accessory sections: Array<EditorSection> = EditorSection.allCases,
        deviceFrame: CGRect,
        onCommit: @escaping ((NSAttributedString) -> Void)
    ) {
        self.attributedText = attributedText
        self.placeholder = placeholder
        self.accessorySections = sections
        self.deviceFrame = deviceFrame
        self.onCommit = onCommit
    }
    
    public var body: some View {
        TextEditorWrapper(attributedText: attributedText, height: $dynamicHeight, placeholder: placeholder, sections: accessorySections, deviceFrame: self.deviceFrame, onCommit: onCommit)
            .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
            
    }
}
