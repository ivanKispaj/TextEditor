
<h1> TextEditor </h1>

<h2>Platform:              IOS</h2>
<h2>Minimum IOS version: IOS 15...</h2>
<p>Installation using Swift package manager: <a href="https://github.com/ivanKispaj/TextEditor">https://github.com/ivanKispaj/TextEditor.git </a> </p>
<p>After run "Update Package" to update the package to the latest version </p>
<h3>Preview </h3>

![TextEditor](https://user-images.githubusercontent.com/91827767/211144170-315172f2-b52d-4560-aefb-f99c1b2d5308.gif)


<h3>  Using </h3>
<h4> Add the package to your app </h4>
<p> To redraw the image in proportion to the orientation of the screen, you need to change the value of the transmitted property: deviceOrientation. </p>
          
```Swift
struct ContentView: View {
    @EnvironmentObject var scene: SceneDelegate
    @EnvironmentObject var appDelegate: AppDelegate
    @State var string: NSAttributedString = NSAttributedString(string: "")

    private var frame: CGRect {
        if let deviceFrame = scene.window?.frame {
            if appDelegate.deviceOrientation == .lanscape {
                return CGRect(x: 0, y: 0, width: deviceFrame.height, height: deviceFrame.width)
            } else {
                return CGRect(x: 0, y: 0, width: deviceFrame.width, height: deviceFrame.height)
            }
        }
            return CGRect(x: 0, y: 0, width: 200, height: 200)
    }
    
    var body: some View {
        
        ScrollView(.vertical ,showsIndicators: false) {
                HStack {
                    TextEditor( attributedText: NSMutableAttributedString(attributedString: string) , deviceFrame: self.frame, onCommit: { text in
                        self.string = text
                    })
                   
                }
        }
    }
}
```
<h5> Scene Delegate to get a device frame can be implemented as follows: </h5>

```Swift
class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    
    @Published var window: UIWindow?
    
    func scene( _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions ) {
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
        }
    }
}
```
<h5> AppDelegate, you can implement the following: </h5>

```Swift
enum ScreenOrientation {
    case lanscape
    case portrait
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published private(set) var deviceOrientation: ScreenOrientation = UIDevice.current.orientation.isLandscape ? .lanscape : .portrait

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
            self.deviceOrientation = .lanscape
        }

        if UIDevice.current.orientation.isPortrait {
            self.deviceOrientation = .portrait
        }
    }
}
```

<h5> In the main file of your application, add the delegate adapter</h5>

```Swift

@main
struct YourApplication: App {

    @UIApplicationDelegateAdaptor var delegate: AppDelegate // !!!! insert this
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```
