//
//  SettingsViewController.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 24/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import iAd

class SettingsViewController: UIViewController, ADBannerViewDelegate {

    @IBOutlet weak var iAdBanner: ADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.iAdBanner.delegate = self
        self.iAdBanner.alpha = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: ADBannerViewDelegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.iAdBanner.alpha = 1.0
        })
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println("SettingsVC's iAd Error: \(error)")
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.iAdBanner.alpha = 0.0
        })
    }

}
