//
//  SelecrtedTextFormat.swift
//  Tasks
//
//  Created by Ivan Konishchev on 03.01.2023.
//

import SwiftUI

@available(iOS 13.0, *)
struct SelecrtedTextFormat {
    private var _bold: UIMenuElement.State = .off
    var bold: UIMenuElement.State {
        get {
            return _bold
        }
        set {
            if newValue == .on && self.italic == .on {
                self.italic = .off
            }
            self._bold = newValue
        }
    }
    private var _italic: UIMenuElement.State = .off
    var italic: UIMenuElement.State  {
        get {
            return _italic
        }
        set {
            if newValue == .on && self.bold == .on {
                self.bold = .off
            }
            self._italic = newValue

        }
    }
    
    var underline: UIMenuElement.State = .off
    var strikethrough: UIMenuElement.State = .off
    
}
