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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let path = NSBundle.mainBundle().pathForResource("Loading", ofType: "gif")
        if let path = path {
            let url = NSURL(fileURLWithPath: path)!
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            // The photo library is available
            
//            var photoLibraryController = UIImagePickerController()
//            // Thanks to the delegate we will be able to know which photos the user is tapping on inside our photo library
//            photoLibraryController.delegate = self
//            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            
//            // Specify the media types for our media controller, in our case it is media data
//            let mediaTypes:[AnyObject] = [kUTTypeImage]
//            photoLibraryController.mediaTypes = mediaTypes
//            photoLibraryController.allowsEditing = false
            
            self.dataImageView.stopAnimating()
            
            var asset = PHAsset()
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
//                let url = NSURL(fileURLWithPath: "assets-library://asset/asset.JPG?id=AC072879-DA36-4A56-8A04-4D467C878877&ext=JPG")
                let url = NSURL(string: "assets-library://asset/asset.JPG?id=AC072879-DA36-4A56-8A04-4D467C878877&ext=JPG")
                var fetchResult = PHFetchResult()
//                fetchResult = PHAsset.fetchAssetsWithALAssetURLs([url as AnyObject!], options: nil)
                fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
                asset = fetchResult[1] as PHAsset
                println("\(asset) -------")
                
                for var indx:Int = 0; indx < fetchResult.count; indx++ {
                    asset = fetchResult[indx] as PHAsset
                    self.otherMethod(asset)
                }
                
                
            }, completionHandler: { (success, error) -> Void in
//                println("Error \(error)")
            })
            
            

//            var result = PHFetchResult()
//            result = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
//            result.enumerateObjectsUsingBlock({ (asset, indx, stop) -> Void in
//                
//
//            })
//            
//            println(result[0])
            
            // Present the photo library controller to the screen
//            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            println("Error in 0002")
        }
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

