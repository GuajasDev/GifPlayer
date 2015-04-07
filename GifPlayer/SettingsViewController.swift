//
//  SettingsViewController.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 24/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import iAd

let kRefreshLibraryOnLaunch = "RefreshLibraryOnLaunch"
let kImportAllPhotosFromLibrary = "ImportAllPhotosFromLibrary"
let kSeparateSectionsByWeek = "SeparateSectionsByWeek"

class SettingsViewController: UIViewController, ADBannerViewDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets

    @IBOutlet weak var iAdBanner: ADBannerView!
    @IBOutlet weak var refreshLibrarySwitch: UISwitch!
    @IBOutlet weak var importAllPhotosSwitch: UISwitch!
    @IBOutlet weak var separateSectionsSwitch: UISwitch!
    
    // MARK: - BODY
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the iAdBanner
        self.iAdBanner.delegate = self
        self.iAdBanner.alpha = 0.0
        
        // Set the values (saved in NSUserDefaults) for the switches
        self.refreshLibrarySwitch.setOn(NSUserDefaults.standardUserDefaults().boolForKey(kRefreshLibraryOnLaunch), animated: false)
        self.importAllPhotosSwitch.setOn(NSUserDefaults.standardUserDefaults().boolForKey(kImportAllPhotosFromLibrary), animated: false)
        self.separateSectionsSwitch.setOn(NSUserDefaults.standardUserDefaults().boolForKey(kSeparateSectionsByWeek), animated: false)
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
    
    // MARK: IBActions
    
    @IBAction func refreshLibrarySwitchDidChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.enabled, forKey: kRefreshLibraryOnLaunch)
    }
    
    @IBAction func importAllPhotosSwitchDidChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.enabled, forKey: kImportAllPhotosFromLibrary)
    }
    
    @IBAction func separateSectionsSwitchDidChange(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.enabled, forKey: kSeparateSectionsByWeek)
    }
}
