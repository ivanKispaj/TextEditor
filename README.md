
<h1> TextEditor </h1>

<h2>Platform:              IOS</h2>
<h2>Minimum IOS version: IOS 15...</h2>
<p>Installation using Swift package manager: <a href="https://github.com/ivanKispaj/TextEditor">https://github.com/ivanKispaj/TextEditor.git </a> </p>
<p>After run "Update Package" to update the package to the latest version </p>
<h3>  Using </h3>
<h4> Add the package to your app </h4>
<p> To redraw the image in proportion to the orientation of the screen, you need to change the value of the transmitted property: deviceOrientation. </p>
          
```Swift
import SwiftUI
import TextEditor

struct ContentView: View {
    @EnvironmentObject var scene: SceneDelegate   // 
    @EnvironmentObject var appDelegate: AppDelegate   //
    @State var string: NSAttributedString = NSAttributedString(string: "")
    private var deviceOrientation: DeviceOrientation {
        self.appDelegate.deviceOrientation == "Landscape" ? DeviceOrientation.Landscape : DeviceOrientation.portrait
    }

    
      var body: some View {
        
        ScrollView(.vertical ,showsIndicators: false) {
                HStack {
                    TextEditor(deviceOrientation: deviceOrientation, attributedText: NSMutableAttributedString(attributedString: string) , deviceFrame: scene.sceneSize, onCommit: { text in
                        self.string = text
                    })
                }
        }
    }
}
```
<h5> Scene Delegate to get a device frame can be implemented as follows: </h5>

```Swift
import Foundation
import SwiftUI

enum ScreenOrientation {
    case lanscape
    case portrait
}
class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    
    var window: UIWindow?
    @Published private(set) var sceneSize: CGRect?
    
    func scene( _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions ) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            sceneSize = window.screen.bounds
        }
    }
}
```
<h5> AppDelegate, you can implement the following: </h5>

```Swift
import Foundation
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published private(set) var deviceOrientation: String = UIDevice.current.orientation.isLandscape ? "Landscape" : "Portrait"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)

        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            self.deviceOrientation = "Landscape"
        }

        if UIDevice.current.orientation.isPortrait {
            self.deviceOrientation = "Portrait"
        }
    }
}
```
<p> And add the AppDelegate adapter as follows : </p>

```Swift
//The main file of your application
    @main
struct YourApplication: App {

    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
                ContentView()
        }
    }
}
```
