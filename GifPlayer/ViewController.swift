//
//  ViewController.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 10/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import iAd

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ADBannerViewDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets
    
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iAdBanner: ADBannerView!
    
    // MARK: Variables
    
    var thisGIFItem:GIFItem!
    
    // MARK: - BODY
    
    // MARK: Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.iAdBanner.delegate = self
        self.iAdBanner.alpha = 0.0
        
        self.fetchImageAssetWithURLString(self.thisGIFItem.imageURL)
        self.title = self.thisGIFItem.imageCaption
        self.titleLabel.text = self.thisGIFItem.imageCaption
        
        self.titleLabel.hidden = true
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
        println("ViewController's iAd Error: \(error)")
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.iAdBanner.alpha = 0.0
        })
    }
    
    // MARK: Image Asset Handlers
    
    func fetchImageAssetWithURLString(url: String) {
        
        var gifImage:PHAsset!
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            // Fetch all the images from the photo library
            var fetchResult = PHFetchResult()
            fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
            
            // Loop through all the fetched images. The 'displayImageAsset' func will only display the image that correspongs to the url in thisGIFItem
            for var indx:Int = 0; indx < fetchResult.count; indx++ {
                gifImage = fetchResult[indx] as PHAsset
                self.displayThisImageAsset(gifImage)
            }
            
            
            }, completionHandler: { (success, error) -> Void in
                if error != nil { println("Error \(error)") }
        })
    }
    
    func displayThisImageAsset(asset: PHAsset) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false
        
        // Get the url of the asset that was passed, if its url is the same as the urlin thisGIFItem then display it and animate it
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            let url = (info["PHImageFileURLKey"] as NSURL).absoluteString!
            if url == self.thisGIFItem.imageURL {
                self.animateImageWithData(NSData(data: imageData))
            }
        })
    }
    
    // MARK: Helpers
    
    func animateImageWithData(imageData: NSData) {
        var testImage = UIImage.animatedImageWithAnimatedGIFData(imageData)
        self.gifImageView.animationImages = testImage.images
        self.gifImageView.animationDuration = testImage.duration
        self.gifImageView.animationRepeatCount = 0
        /* If I want the animation to stop in the last frame, set 'animationRepeatCount' to 1 and uncomment this
        self.gifImageView.image = testImage.images!.last as! UIImage! */
        self.gifImageView.startAnimating()
    }
    
    // MARK: Terminating
    
    override func viewWillDisappear(animated: Bool) {
        // Called before the view is dismissed
        self.gifImageView.stopAnimating()
        self.navigationController?.toolbarHidden = true
    }
}

// MARK: - PHAsset Class Extension

extension PHAsset {
    class func fetchAssetWithALAssetURL (alURL: NSURL) -> PHAsset? {
        let phPhotoLibrary = PHPhotoLibrary.sharedPhotoLibrary()
        let assetManager = PHImageManager()
        var phAsset : PHAsset?
        
        let optionsForFetch = PHFetchOptions()
        optionsForFetch.includeHiddenAssets = true
        
        var fetchResult = PHAsset.fetchAssetsWithALAssetURLs([alURL], options: optionsForFetch)
        if fetchResult?.count > 0 {
            return fetchResult[0] as? PHAsset
        } else {
            var str = alURL.absoluteString!
            let startOfString = advance(find(str, "=")!, 1)
            let endOfString = advance(startOfString, 36)
            let range = Range<String.Index>(start:startOfString, end:endOfString)
            let localIDFragment = str.substringWithRange(range)
            let fetchResultForPhotostream = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.AlbumMyPhotoStream, options: nil)
            if fetchResultForPhotostream?.count > 0 {
                let photostream = fetchResultForPhotostream![0] as PHAssetCollection
                let fetchResultForPhotostreamAssets = PHAsset.fetchAssetsInAssetCollection(photostream, options: optionsForFetch)
                if fetchResultForPhotostreamAssets?.count >= 0 {
                    var stop : Bool = false
                    for var i = 0; i < fetchResultForPhotostreamAssets.count && !stop; i++ {
                        let phAssetBeingCompared = fetchResultForPhotostreamAssets[i] as PHAsset
                        if phAssetBeingCompared.localIdentifier.rangeOfString(localIDFragment, options: nil, range: nil, locale: nil) != nil {
                            phAsset = phAssetBeingCompared
                            stop = true
                        }
                    }
                    return phAsset
                }
            }
            return nil
        }
    }
}
