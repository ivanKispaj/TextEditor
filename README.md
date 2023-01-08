
<h1> TextEditor </h1>

<h2>Platform:              IOS</h2>
<h2>Minimum IOS version: IOS 15...</h2>
<p>Installation using Swift package manager: <a href="https://github.com/ivanKispaj/TextEditor">https://github.com/ivanKispaj/TextEditor.git </a> </p>
<p>After run "Update Package" to update the package to the latest version </p>
<h3>Preview </h3>

![TextEditor](https://user-images.githubusercontent.com/91827767/211144170-315172f2-b52d-4560-aefb-f99c1b2d5308.gif)


<h3>  Using </h3>
<h4> Add the package to your app </h4>
          
```Swift
import SwiftUI
import TextEditor // !!!

struct ContentView: View {

    @State var string: NSAttributedString = NSAttributedString(string: "")
    
    var body: some View {
        
        ScrollView(.vertical ,showsIndicators: false) {
                HStack {
                    TextEditor( attributedText: NSMutableAttributedString(attributedString: string), onCommit: { text in
                            self.string = text                     
                    })
                   
                }
        }
    }
}
```
