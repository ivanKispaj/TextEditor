//
//  EditorInstruments.swift
//  Tasks
//
//  Created by Ivan Konishchev on 30.12.2022.
//

import Foundation

/// Options for toolbar sections
public enum EditorSection: CaseIterable {
    
    case fontFormat
    case fontStyle
    case textAlignment
    case image
    case color
    case keyboard
}

// Text format:largeHeader,header,smallHeader,plainText
/// rawValue - contain default text size values
public enum TextStyleFormat: CGFloat {
    case largeHeader = 32
    case header = 26
    case smallHeader = 22
    case plainText = 14
}
