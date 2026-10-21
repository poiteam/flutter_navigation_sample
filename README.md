# PoilabsNavigation Flutter Integration

Flutter sample for navigation SDK

## Getting Started

This project is just a sample to implement poiLabs Navigation SDK in a flutter project.

## iOS SIDE

PoilabsNavigation provides a native iOS UIView. You can add this view to your Flutter app with Platform Views. For general information about hosting native iOS views in your Flutter app with Platform Views, see the official Flutter docs with link below.

[Hosting native iOS views in your Flutter app with Platform Views](https://docs.flutter.dev/development/platform-integration/ios/platform-views)

### Requirements

| | |
|---|---|
| PoilabsNavigation | 7.3.1 |
| Minimum iOS | 14.0 |
| Installation | Swift Package Manager |

### Installation

PoilabsNavigation is distributed with **Swift Package Manager (SPM)**. CocoaPods is no longer supported; new versions are not published there.

A Flutter app is a normal Xcode project on the iOS side, so you add the package to the **Runner** target:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select **File > Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/poiteam/ios-navigation-pod.git`
4. Choose **Exact Version** `7.3.1` and add the **PoilabsNavigation** product to the **Runner** target.
5. Set the iOS deployment target of the Runner target (and `platform :ios` in your `Podfile`, if you have one) to **14.0** or higher.

The package contains everything the SDK needs: PoilabsNavigation, PoilabsMapView, PoilabsCommon and Mapbox Maps 11.18.0. PoilabsPositioning, PoilabsSdkAnalytics and PoilabsCore are resolved automatically. You do not need to add Mapbox or any other dependency yourself.

> The first package resolution can take a few minutes because the package contains the Mapbox frameworks.

**Notes**

- The SDK ships its own Mapbox Maps 11.18.0. If your app (or another Flutter plugin) also adds Mapbox Maps, the two copies conflict.
- Flutter's own `Podfile` stays as it is; Flutter still uses it for your other plugins. You only remove the Poilabs lines from it.

### Migrating from CocoaPods

If you integrated an older version with `pod 'PoilabsNavigation'`:

1. Remove `pod 'PoilabsNavigation'` from `ios/Podfile`, together with any `PoilabsCore`, `PoilabsPositioning`, `PoilabsSdkAnalytics`, `Mapbox-iOS-SDK` or `MapboxMobileEvents` lines.
2. Run `pod install` in the `ios` folder (or `pod deintegrate` if no other pods remain).
3. Add the package with Swift Package Manager as described above.

Do not keep the SDK in your Podfile while it is added with SPM; the same frameworks would be embedded twice.

### Pre-Requirements

Add the following keys to your `ios/Runner/Info.plist` file:

- **Privacy - Location Usage Description**
- **Privacy - Location When In Use Usage Description**
- **Privacy - Bluetooth Peripheral Usage Description**
- **Privacy - Bluetooth Always Usage Description**

`MGLMapboxMetricsEnabledSettingShownInApp` was needed only by the old Mapbox SDK; you can remove it.

### PoilabsMapView File

Create a swift file called PoilabsMapView.swift

Set these properties **before** calling `getReadyForStoreMap`:

| Property | |
|---|---|
| `applicationId` | Required — provided by PoiLabs |
| `applicationSecret` | Required — provided by PoiLabs |
| `navigationUniqueIdentifier` | Required — unique per app user |
| `applicationLanguage` | `en`, `tr`, `hr`, `ar`, `de`, `ru`, `pl` — default: `tr` |

In this sample the credentials are read from `ios/Flutter/Secrets.xcconfig` (copy `Secrets.xcconfig.example`; the file is git-ignored).

```swift
import UIKit
import PoilabsNavigation

class PoilabsMapView: UIView, PLNNavigationMapViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let settings = PLNNavigationSettings.sharedInstance()
        settings?.applicationId = "APPLICATION_ID"
        settings?.applicationSecret = "APPLICATION_SECRET_KEY"
        settings?.navigationUniqueIdentifier = "UNIQUE_ID"
        settings?.applicationLanguage = "tr"

        PLNavigationManager.sharedInstance()?.getReadyForStoreMap(completionHandler: { (error) in
            if error == nil {
                let carrierView = PLNNavigationMapView(frame: self.bounds)
                carrierView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                carrierView.awakeFromNib()
                carrierView.delegate = self
                self.addSubview(carrierView)
            } else {
                print("PoiLabs SDK init failed: \(String(describing: error))")
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

@main
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

### Requirements

| | |
|---|---|
| PoilabsNavigation | 8.1.1 |
| Minimum Android | API 24 (Android 7.0) |
| Compile SDK | 35 or higher |
| JDK (local / CI) | 17 |

### Installation

For starters you should add the PoiLabs and Mapbox repositories to the project level `android/build.gradle`. **JITPACK_TOKEN** and **MAPBOX_TOKEN** are provided by PoiLabs. In this sample they are read from `android/local.properties`, which is not committed.

```groovy
def localProperties = new Properties()
def localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { localProperties.load(it) }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url "https://api.mapbox.com/downloads/v2/releases/maven"
            authentication {
                basic(BasicAuthentication)
            }
            credentials {
                username = "mapbox"
                password = localProperties.getProperty("MAPBOX_TOKEN", "")
            }
        }
        maven {
            url "https://jitpack.io"
            credentials { username = localProperties.getProperty("JITPACK_TOKEN", "") }
        }
    }
}
```

The old `https://oss.jfrog.org/artifactory/oss-snapshot-local/` repository is no longer needed; remove it.

Then add the SDK to the app level `android/app/build.gradle` and set `minSdk` to 24:

```groovy
android {
    defaultConfig {
        minSdk 24
    }
}

dependencies {
    implementation 'com.github.poiteam:Android-Navigation-SDK:8.1.1'
    implementation 'androidx.appcompat:appcompat:1.7.0'
}
```

The SDK adds its location and Bluetooth permissions to your manifest. On Android 12+ the launcher activity must declare `android:exported="true"`.

The SDK ships its consumer ProGuard rules inside the AAR, so you do not need to copy SDK keep rules into your app.

### Usage

Register a channel in `MainActivity`. It should look like this:

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

> **Upgrading from 7.x or older:** Since 8.0.0 `onReady` takes a non-null `MapFragment` and `onStatusChanged` takes a non-null `PLPStatus`. If your code overrides them as `MapFragment?` / `PLPStatus?`, change the parameter types as shown below, otherwise Kotlin reports *"overrides nothing"*.

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
            override fun onReady(mapFragment: MapFragment) {
                supportFragmentManager.beginTransaction()
                    .replace(R.id.main_act_layout, mapFragment)
                    .commit()
            }

            override fun onStoresReady() {

            }

            override fun onError(exception: Throwable?) {

            }

            override fun onStatusChanged(plpStatus: PLPStatus) {

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
