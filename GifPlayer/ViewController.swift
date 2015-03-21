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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets

    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: Variables
    
    var thisGIFItem:GIFItem!
    
    // MARK: - BODY
    
    // MARK: System Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fetchImageAssetWithURLString(self.thisGIFItem.imageURL)
        self.titleLabel.text = self.thisGIFItem.imageCaption
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        // Called before the view is dismissed
        self.gifImageView.stopAnimating()
    }
    
    // MARK: Image Asset Handlers
    
    func fetchImageAssetWithURLString(url: String) {
        
        var gifImage:PHAsset!
        
        if thisGIFItem.selectedFromPicker == false {
            // The image was loaded automatically
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                // Fetch all the images from the photo library
                var fetchResult = PHFetchResult()
                fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
                
                // Loop through all the fetched images. The displayImageAsset will only display the image that correspongs to the
                for var indx:Int = 0; indx < fetchResult.count; indx++ {
                    gifImage = fetchResult[indx] as PHAsset
                    self.displayThisImageAsset(gifImage)
                }
                
                
                }, completionHandler: { (success, error) -> Void in
                    println("Error \(error)")
            })
            
        } else {
            // The image was chosen with the UIImagePicker
            
            // Transform the URL saved in core data from a String to a NSURL and fetch the image
            let url = NSURL(string: url as String)!
            gifImage = PHAsset.fetchAssetWithALAssetURL(url)
            
            // If there is actually an image asset, then display it
            if gifImage != nil {
                PHImageManager.defaultManager().requestImageDataForAsset(gifImage, options: nil, resultHandler: { (data:NSData!, string:String!, orientation:UIImageOrientation, object:[NSObject : AnyObject]!) -> Void in
                    self.animateImageWithData(data)
                })
                
            } else {
                println("Error in 0001")
            }
        }
    }
    
    func displayThisImageAsset(asset: PHAsset) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false
        
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
