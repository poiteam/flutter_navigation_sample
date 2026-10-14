//
//  PoilabsMapView.swift
//  Runner
//
//  Created by Emre Kuru on 23.03.2023.
//

import UIKit
import PoilabsNavigation

class PoilabsMapView: UIView, PLNNavigationMapViewDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        let settings = PLNNavigationSettings.sharedInstance()
        settings?.applicationId = Bundle.main.object(forInfoDictionaryKey: "PoilabsApplicationId") as? String ?? ""
        settings?.applicationSecret = Bundle.main.object(forInfoDictionaryKey: "PoilabsApplicationSecret") as? String ?? ""
        settings?.navigationUniqueIdentifier = "YOUR_USER_UNIQUE_ID"
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
