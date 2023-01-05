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
    
    private var deviceOrientation: DeviceOrientation
    private var deviceFrame: CGRect
    @State var dynamicHeight: CGFloat = 100
    private let attributedText: NSMutableAttributedString
    private let placeholder: String
    private let accessorySections: Array<EditorSection>
    private let onCommit: (NSAttributedString) -> Void
    public init(
        deviceOrientation:  DeviceOrientation,
        attributedText: NSMutableAttributedString,
        placeholder: String = "",
        accessory sections: Array<EditorSection> = EditorSection.allCases,
        deviceFrame: CGRect,
        onCommit: @escaping ((NSAttributedString) -> Void)
    ) {
        self.attributedText = attributedText
        self.deviceOrientation = deviceOrientation
        self.placeholder = placeholder
        self.accessorySections = sections
        self.deviceFrame = deviceFrame
        self.onCommit = onCommit
        NotificationCenter.default.post(name: NSNotification.Name("deviceOrientationChanged"),
            object: nil,
            userInfo: ["deviceOrientation": deviceOrientation])
    }
    
    public var body: some View {
            TextEditorWrapper(attributedText: attributedText, height: $dynamicHeight, placeholder: placeholder, sections: accessorySections, deviceFrame: self.deviceFrame, onCommit: onCommit)
                .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
    }
}
