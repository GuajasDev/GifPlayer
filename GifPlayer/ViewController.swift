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

    @IBOutlet weak var dataImageView: UIImageView!
    
    var thisGIFItem:GIFItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = NSURL(string: self.thisGIFItem.imageURL as String)!
        var gifImage:PHAsset!
        
        if thisGIFItem.selectedFromPicker == true {
            // The image was chosen with the UIImagePicker
            
            gifImage = PHAsset.fetchAssetWithALAssetURL(url)
            
            if gifImage != nil {
                PHImageManager.defaultManager().requestImageDataForAsset(gifImage, options: nil, resultHandler: { (data:NSData!, string:String!, orientation:UIImageOrientation, object:[NSObject : AnyObject]!) -> Void in
                    var testImage = UIImage.animatedImageWithAnimatedGIFData(data)
                    self.dataImageView.animationImages = testImage.images
                    self.dataImageView.animationDuration = testImage.duration
                    self.dataImageView.animationRepeatCount = 0
                    /* If I want the animation to stop in the last frame, set 'animationRepeatCount' to 1 and uncomment this
                    self.dataImageView.image = testImage.images!.last as! UIImage! */
                    self.dataImageView.startAnimating()
                })
            
            } else {
                println("Error in 0001")
            }
            
        } else {
            // The image was loaded automatically
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
                var fetchResult = PHFetchResult()
                fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
                
                for var indx:Int = 0; indx < fetchResult.count; indx++ {
                    gifImage = fetchResult[indx] as PHAsset
                    self.displayImageAsset(gifImage)
                }
                
                
                }, completionHandler: { (success, error) -> Void in
                    println("Error \(error)")
            })
        }
    }

    @IBAction func syncButtonPressed(sender: UIButton) {
        // The photo library is available
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
            // The user has granted access to the photo library
            println("Authorised")
        } else if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Denied {
            // The user has denied access to the photo library
            println("Denied")
        } else if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Restricted {
            // Access to the photo library is denied and the user cannot grant such permission
            println("Restricted")
        } else if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.NotDetermined {
            // The user has not determined yet if you can have access to the photo library or not
            println("Not Determined")
        }
        
        self.dataImageView.stopAnimating()
        
        var asset = PHAsset()
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            var fetchResult = PHFetchResult()
            fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
            
            for var indx:Int = 0; indx < fetchResult.count; indx++ {
                asset = fetchResult[indx] as PHAsset
                self.displayImageAsset(asset)
            }
            
            
            }, completionHandler: { (success, error) -> Void in
                println("Error \(error)")
        })
    }
    
    func displayImageAsset(asset: PHAsset) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false
        
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            
            let url = (info["PHImageFileURLKey"] as NSURL).absoluteString!
            
            if url == self.thisGIFItem.imageURL {
                println("YAY")
                println("////")
                
                var testImage = UIImage.animatedImageWithAnimatedGIFData(NSData(data: imageData))
                self.dataImageView.animationImages = testImage.images
                self.dataImageView.animationDuration = testImage.duration
                self.dataImageView.animationRepeatCount = 0
                /* If I want the animation to stop in the last frame, set 'animationRepeatCount' to 1 and uncomment this
                self.dataImageView.image = testImage.images!.last as! UIImage! */
                self.dataImageView.startAnimating()
                
            } else {
                println("NAY")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

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
