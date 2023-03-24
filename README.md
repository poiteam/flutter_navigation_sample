# PoilabsNavigation Flutter Integration

Flutter sample for navigation SDK

## Getting Started

This project is just a sample to implement poiLabs Navigation SDK in a flutter project.

## iOS SIDE

[![Version](https://img.shields.io/cocoapods/v/PoilabsNavigation.svg?style=flat)](https://cocoapods.org/pods/PoilabsNavigation)
[![Platform](https://img.shields.io/cocoapods/p/PoilabsNavigation.svg?style=flat)](https://cocoapods.org/pods/PoilabsNavigation)

PoilabsNavigation provides a native iOS UIView. You can add this view to your Flutter app with Platform Views. For general information about hosting native iOS views in your Flutter app with Platform Views, see the official Flutter docs with link below.

[Hosting native iOS views in your Flutter app with Platform Views](https://docs.flutter.dev/development/platform-integration/ios/platform-views)

### Installation

To integrate PoilabsNavigation into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'PoilabsNavigation'
```

Tip: CocoaPods provides a pod init command to create a Podfile with smart defaults. You should use it.

Now you can install the dependencies in your project:

```ruby
$ pod install
```

Make sure to always open the Xcode workspace instead of the project file when building your project:

```ruby
$ open App.xcworkspace
```

### Pre-Requirements

To Integrate this framework you should add some features to your project info.plist file.

+MGLMapboxMetricsEnabledSettingShownInApp : YES

+Privacy - Location When In Use Usage Description

### PoilabsMapView File

Create a swift file called PoilabsMapView.swift

```swift
import UIKit
import PoilabsNavigation

class PoilabsMapView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        PLNNavigationSettings.sharedInstance().applicationId = "application_id"
        PLNNavigationSettings.sharedInstance().applicationSecret = "application_secret_key"
        PLNNavigationSettings.sharedInstance().applicationLanguage = "tr"

        PLNavigationManager.sharedInstance()?.getReadyForStoreMap(completionHandler: { (error) in
            if error == nil {
                let carrierView = PLNNavigationMapView(frame: self.frame)
                carrierView.awakeFromNib()
                self.addSubview(carrierView)
            } else {
                //show error
            }
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

### FLNativeViewFactory File

Create a swift file called FLNativeViewFactory.swift 

Implement the factory and the platform view. The FLNativeViewFactory creates the platform view, and the platform view provides a reference to the PoilabsMapView.

```swift
import Flutter
import UIKit

class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLNativeView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class FLNativeView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        _view = PoilabsMapView(frame: frame)
        super.init()
    }

    func view() -> UIView {
        return _view
    }
}
```

### FLPlugin File

Create a file called FLPlugin.swift

```swift
import Flutter
import UIKit

class FLPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "PoilabsMapView")
    }
}
```

### AppDelegate.swift File

Finally, register the platform view. This can be done in an app or a plugin.

For app registration, modify the App’s AppDelegate.swift:

```swift
import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        weak var registrar = self.registrar(forPlugin: "plugin-name")

        let factory = FLNativeViewFactory(messenger: registrar!.messenger())
        self.registrar(forPlugin: "PoilabsMapViewPlugin")!.register(
            factory,
            withId: "PoilabsMapView")
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

## Android SIDE
For starters you should add dependencies to android project level build.gradle.
For this part you can follow native documentation
```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://jitpack.io"
            Properties properties = new Properties()
            properties.load(project.rootProject.file('local.properties').newDataInputStream())
            credentials { username =properties.getProperty('jitpackToken') }
        }
        maven {
            url 'https://api.mapbox.com/downloads/v2/releases/maven'
            authentication {
                basic(BasicAuthentication)
            }
            Properties properties = new Properties()
            properties.load(project.rootProject.file('local.properties').newDataInputStream())
            credentials {
                username = 'mapbox'
                password = properties.getProperty('MAP_BOX_TOKEN')
            }
        }
        maven { url 'https://oss.jfrog.org/artifactory/oss-snapshot-local/' }
    }
}

```

and then add navigation sdk implementation in app level build.gradle

```groovy
    implementation 'com.github.poiteam:Android-Navigation-SDK:v3.0.35'
```

then you should register a channel in Main activity 
basically Main activity should look like this

```kotlin
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.poilabs/navigationChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                if (call.method?.contentEquals("start") == true) {
                    Intent(this, NavigationActivity::class.java).also {
                        startActivity(it)
                        result.success("ActivityStarted")
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}

```

Add another Activity called NavigationActivity and init sdk there.

```kotlin

class NavigationActivity : AppCompatActivity() {


    companion object {
        private const val TAG = "MainActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_navigation)
        initSDK()

    }

    private fun initSDK() {
        PoiNavigation.getInstance().clearResources()
        val localeLanguage: String = Locale.forLanguageTag(Locale.getDefault().language).toString()
        val poiSdkConfig = PoiSdkConfig(
            appId = BuildConfig.APPID,
            secret = BuildConfig.APPSECRET,
            uniqueId = "YOUR USER UNIQUE ID"
        )
        PoiNavigation.getInstance(
            this,
            localeLanguage,
            poiSdkConfig
        ).bind(object : PoiNavigation.OnNavigationReady {
            override fun onReady(p0: MapFragment?) {
                p0?.let {
                    supportFragmentManager.beginTransaction().replace(R.id.main_act_layout, it)
                        .commit()
                }
            }

            override fun onStoresReady() {

            }

            override fun onError(p0: Throwable?) {

            }

            override fun onStatusChanged(p0: PLPStatus?) {

            }

        })
    }

}
```

On the dart side you can now just call this channel to open Navigation activity 

```dart
class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.poilabs/navigationChannel');

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
        return UiKitView(
            viewType: "PoilabsMapView",
            creationParams: null,
            creationParamsCodec: const StandardMessageCodec());
    } else if (defaultTargetPlatform == TargetPlatform.android) {
        return Scaffold(
            appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(widget.title),
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: _startNavigation,
                tooltip: 'Start Navigation',
                child: const Icon(Icons.map),
            ), // This trailing comma makes auto-formatting nicer for build methods.
        );
    } else {
        return Text("Not supported");
    }
  }

  Future<void> _startNavigation() async {
    await platform.invokeMethod('start');
  }
}
```