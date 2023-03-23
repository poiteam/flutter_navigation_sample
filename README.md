# flutter_navigation_sample

Flutter sample for navigation SDK

## Getting Started

This project is just a sample to implement poiLabs Navigation SDK in a flutter project.

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
  }

  Future<void> _startNavigation() async {
    await platform.invokeMethod('start');
  }
}
```