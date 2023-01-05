<<<<<<< HEAD
# TextEditor

```Swift
import SwiftUI
import TextEditor

struct ContentView: View {
    @State var string: NSAttributedString = NSAttributedString(string: "")
    @State var orientation: DeviceOrientation = .portrait
    var body: some View {
        ScrollView(.vertical,showsIndicators: false) {
            
                VStack {
                    TextEditor(deviceOrientation: orientation, attributedText: NSMutableAttributedString(attributedString: string), deviceFrame: CGRect(x: 0, y: 0, width: geo.size.width, height: geo.size.height)) { newString in
                        self.string = newString
                    }
                }
            }
    }
}

```
