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
        
        let path = NSBundle.mainBundle().pathForResource("Loading", ofType: "gif")
        if let path = path {
            let url = NSURL(fileURLWithPath: path)!
            println(NSData(data: self.thisGIFItem.image))
            println("\n----------\n")
            println(NSData(contentsOfURL: url))
//            var testImage = UIImage.animatedImageWithAnimatedGIFData(NSData(data: self.thisGIFItem.image))
            var testImage = UIImage.animatedImageWithAnimatedGIFData(NSData(contentsOfURL: url))
            self.dataImageView.animationImages = testImage.images
            self.dataImageView.animationDuration = testImage.duration
            self.dataImageView.animationRepeatCount = 0
            /* If I want the animation to stop in the last frame, set 'animationRepeatCount' to 1 and uncomment this
            self.dataImageView.image = testImage.images!.last as! UIImage! */
            self.dataImageView.startAnimating()
            
        } else {
            println("Error in 0001")
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
                self.otherMethod(asset)
            }
            
            
            }, completionHandler: { (success, error) -> Void in
                //                println("Error \(error)")
        })
    }
    
    func otherMethod(asset: PHAsset) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false
        //            imageRequestOptions.resizeMode = PHImageRequestOptionsResizeMode.Exact
        
//        let targetSize = UIScreen.mainScreen().bounds.size
        
//        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.AspectFit, options: imageRequestOptions, resultHandler: { (result, info) -> Void in
////            println("-----------")
////            println(info["PHImageFileUTIKey"])
////            println(info["PHImageFileURLKey"])
////            println("-----------")
//            
//            let url = (info["PHImageFileURLKey"] as NSURL)
//            
//            println(url)
//            
//            if url.absoluteString!.rangeOfString(".gif") != nil {
//                println("yay")
//            } else if url.absoluteString!.rangeOfString(".GIF") != nil {
//                println("YAY")
//                
////                self.dataImageView.stopAnimating()
////                
////                var testImage = UIImage.animatedImageWithAnimatedGIFData(NSData(contentsOfURL: url))
////                self.dataImageView.animationImages = testImage.images
////                self.dataImageView.animationDuration = testImage.duration
////                self.dataImageView.animationRepeatCount = 0
////                /* If I want the animation to stop in the last frame, set 'animationRepeatCount' to 1 and uncomment this
////                self.dataImageView.image = testImage.images!.last as! UIImage! */
////                self.dataImageView.startAnimating()
//                
//                
//            } else {
//                println("NAY")
//            }
//            
//            println("----------")
//        })
        
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            
            let url = (info["PHImageFileURLKey"] as NSURL).absoluteString!
            
            if url.rangeOfString(".GIF") != nil {
                println("YAY")
                
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

