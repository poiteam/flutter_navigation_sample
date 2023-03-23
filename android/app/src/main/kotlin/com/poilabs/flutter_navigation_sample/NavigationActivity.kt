package com.poilabs.flutter_navigation_sample

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.poilabs.navigation.model.PoiNavigation
import com.poilabs.navigation.model.PoiSdkConfig
import com.poilabs.navigation.view.fragments.MapFragment
import com.poilabs.poilabspositioning.model.PLPStatus
import java.util.*

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
