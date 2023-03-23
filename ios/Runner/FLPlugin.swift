//
//  FLPlugin.swift
//  Runner
//
//  Created by Emre Kuru on 23.03.2023.
//

import Flutter
import UIKit

class FLPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "PoilabsMapView")
    }
}

