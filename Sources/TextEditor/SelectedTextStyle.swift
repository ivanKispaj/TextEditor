//
//  SelectedTextStyle.swift
//  Tasks
//
//  Created by Ivan Konishchev on 03.01.2023.
//

import SwiftUI

@available(iOS 13.0, *)
struct SelectedTextStyle {
    private(set) var textStyle: TextStyleFormat = .largeHeader
    
    private var _largeHeader: UIMenuElement.State = .off
    var largeHeader: UIMenuElement.State {
        get {
            return _largeHeader
        }
        set {
            if newValue == .on {
                self.header = .off
                self.smallHeader = .off
                self.plainText = .off
                self.textStyle = .largeHeader

            }
            self._largeHeader = newValue
            
        }
    }
    
    private var _header: UIMenuElement.State = .off
    var header: UIMenuElement.State {
        get {
            return _header
        }
        set {
            if newValue == .on {
                self.plainText = .off
                self.largeHeader = .off
                self.smallHeader = .off
                self.textStyle = .header

            }
            self._header = newValue
        }
    }
    
    private var _smallHeader: UIMenuElement.State = .off
    var smallHeader: UIMenuElement.State {
        get {
            return _smallHeader
        }
        set {
            if newValue == .on {
                self.plainText = .off
                self.largeHeader = .off
                self.header = .off
                self.textStyle = .smallHeader

            }
            self._smallHeader = newValue
        }
    }
    
    private var _plainText: UIMenuElement.State = .off
    var plainText: UIMenuElement.State {
        get {
            return _plainText
        }
        set {
            if newValue == .on {
                self.smallHeader = .off
                self.largeHeader = .off
                self.header = .off
                self.textStyle = .plainText

            }
            self._plainText = newValue
        }
    }
}
