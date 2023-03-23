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
        PLNNavigationSettings.sharedInstance().applicationId = "application_id"
        PLNNavigationSettings.sharedInstance().applicationSecret = "application_secret_key"
        PLNNavigationSettings.sharedInstance().applicationLanguage = "tr"

        PLNavigationManager.sharedInstance()?.getReadyForStoreMap(completionHandler: { (error) in
            if error == nil {
                let carrierView = PLNNavigationMapView(frame: self.frame)
                carrierView.awakeFromNib()
                carrierView.delegate = self
                carrierView.searchBarBaseView.backgroundColor = UIColor.black
                carrierView.searchCancelButton.setTitleColor(.white, for: .normal)
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
