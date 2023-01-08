//
//  TextEditor.swift
//  Tasks
//
//  Created by Ivan Konishchev on 30.12.2022.
//

import SwiftUI

@available(iOS 15.0, *)
public struct TextEditor: View , Equatable {
    
    public static func == (lhs: TextEditor, rhs: TextEditor) -> Bool {
        true
    }
    @State var dynamicHeight: CGFloat = 100
    private let attributedText: NSMutableAttributedString
    private let placeholder: String
    private let accessorySections: Array<EditorSection>
    private let onCommit: (NSAttributedString) -> Void
    public init(
        attributedText: NSMutableAttributedString,
        placeholder: String = "",
        accessory sections: Array<EditorSection> = EditorSection.allCases,
        onCommit: @escaping ((NSAttributedString) -> Void)
    ) {
        self.attributedText = attributedText
        self.placeholder = placeholder
        self.accessorySections = sections
        self.onCommit = onCommit
    }
    
    public var body: some View {
        TextEditorWrapper(attributedText: attributedText, height: $dynamicHeight, placeholder: placeholder, sections: accessorySections, onCommit: onCommit)
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
                
    }
}
