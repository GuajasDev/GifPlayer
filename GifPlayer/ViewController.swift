//
//  ViewController.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 10/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import MobileCoreServices
//import Photos

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
            
            var photoLibraryController = UIImagePickerController()
            // Thanks to the delegate we will be able to know which photos the user is tapping on inside our photo library
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            // Specify the media types for our media controller, in our case it is media data
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false

//            var result = PHFetchResult()
//            result = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
//            result.enumerateObjectsUsingBlock({ (asset, indx, stop) -> Void in
//                
//
//            })
//            
//            println(result[0])
            
            // Present the photo library controller to the screen
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            println("Error in 0002")
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let url = (info["UIImagePickerControllerReferenceURL"] as! NSURL).absoluteString
        
        if (url!.rangeOfString("&ext=GIF") != nil) {
            println("GIF")
        } else {
            println("Not GIF")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

