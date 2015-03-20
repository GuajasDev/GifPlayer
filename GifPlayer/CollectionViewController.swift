//
//  CollectionViewController.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 13/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import Photos

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Variables
    
    // Arrays
    // We use 'AnyObject' because when we 'executeFetchRequest' in viewDidLoad, we get an array with AnyObject instances. We are doing the fetch request manually rather than using the NSFetchResultsController manage this for us as in TaskIt mainly to practice both ways
    var gifArray:[AnyObject] = []
    
    // MARK: - BODY
    
    // MARK: Initialisers

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.fetchGifItemsFromLibrary()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // We are doing the fetch request manually rather than using the NSFetchResultsController manage this for us as in TaskIt mainly to practice both ways
        // Request all the FeedItems we have saved
        let request = NSFetchRequest(entityName: "GIFItem")
        
        // Get the instance of the APpDelegate back
        let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        
        // Get access to the context from the AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        // Execute the fetch request and save the AnyObject instances
        self.gifArray = context.executeFetchRequest(request, error: nil)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Prepare for Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMainVC" {
            var mainVC:ViewController = segue.destinationViewController as ViewController
            mainVC.thisGIFItem = sender as GIFItem
        }
    }
    
    // MARK: IBActions
    
    @IBAction func addBarButtonItemPressed(sender: UIBarButtonItem) {
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
            
            // Present the photo library controller to the screen
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
        } else {
            // Neither the camera nor the photo library are available
            
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library. Please check in Settings if they are enabled for this application", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gifArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:GIFCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("gifCell", forIndexPath: indexPath) as GIFCollectionViewCell
        
        // The row property refers to the cell (ie row 0 is the first cell, row 1 is the second cell, etc...) not the actual rows of cells
        let thisItem = self.gifArray[indexPath.row] as GIFItem
        
        cell.imageView.image = UIImage(data: thisItem.thumbImage)
//        cell.captionLabel.text = thisItem.caption
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = self.gifArray[indexPath.row] as GIFItem
        self.performSegueWithIdentifier("toMainVC", sender: thisItem)
    }
    
    // MARK: UIImagePickerControllerDelegaate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let url = (info["UIImagePickerControllerReferenceURL"] as NSURL).absoluteString!
        
        if url.rangeOfString("ext=GIF") != nil {
            
            // Get the managedObjectContext
            let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
            
            // Create an entityDescription
            let entityDescription = NSEntityDescription.entityForName("GIFItem", inManagedObjectContext: managedObjectContext!)
            
            // Create the FeedItem
            let gifItem = GIFItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
            
            // info is a dictionary that is passed in the function, we are using the 'UIImagePickerControllerOriginalImage' key to get back the value of the (original) UIImage we want to display
            let image = info[UIImagePickerControllerOriginalImage] as UIImage
            
            // Save the image to CoreData. The image will be converted into a data representation (NSData instance, which is a binary representation) of the UIImage instance
            // ********** DONT SAVE THE IMAGE DATA, SAVE THE URL **********
            let imageData = UIImageJPEGRepresentation(image, 0.2)
        
            gifItem.imageURL = url
            gifItem.thumbImage = imageData
            gifItem.selectedFromPicker = true
            gifItem.imageID = getImageID(gifItem.imageURL)
            //        gifItem.caption = "Test Caption"
            (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
            
            // Add the feedItem to the feedArray so the user can see the item without having to quit and restart the application
            self.gifArray.append(gifItem)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            // reload the collectionView data so the user can see the item without having to quit and restart the application
            self.collectionView.reloadData()
            
        } else {
            println("Not GIF")
        }
    }
    
    // MARK: Helpers
    
    func getImageID(url: String) -> String {
        var startOfString:String.Index
        if find(url, "=") != nil {
            startOfString = advance(find(url, "=")!, 1)
        }
        else {
            startOfString = advance(find(url, "-")!, -8)
        }
        let endOfString = advance(startOfString, 36)
        let range = Range<String.Index>(start:startOfString, end:endOfString)
        let localIDFragment = url.substringWithRange(range)
        return localIDFragment
    }
    
    func fetchGifItemsFromLibrary() {
        // Check if the photo library is available
        
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
        
//        self.dataImageView.stopAnimating()
        
        var asset = PHAsset()
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            var fetchResult = PHFetchResult()
            fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
            
            for var indx:Int = 0; indx < fetchResult.count; indx++ {
                asset = fetchResult[indx] as PHAsset
                self.saveImageAsset(asset)
            }
            
            
            }, completionHandler: { (success, error) -> Void in
                println("Error \(error)")
        })
    }
    
    func saveImageAsset(asset: PHAsset) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false

        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            
            let url = (info["PHImageFileURLKey"] as NSURL).absoluteString!
            
            if url.rangeOfString(".GIF") != nil {
                println("YAY")
                
                // Get the managedObjectContext
                let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
                
                // Create an entityDescription
                let entityDescription = NSEntityDescription.entityForName("GIFItem", inManagedObjectContext: managedObjectContext!)
                
                // Create the FeedItem
                let gifItem = GIFItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                
                // info is a dictionary that is passed in the function, we are using the 'UIImagePickerControllerOriginalImage' key to get back the value of the (original) UIImage we want to display
//                let image = info[UIImagePickerControllerOriginalImage] as UIImage
                
                // Save the image to CoreData. The image will be converted into a data representation (NSData instance, which is a binary representation) of the UIImage instance
                // ********** DONT SAVE THE IMAGE DATA, SAVE THE URL **********
//                let imageData = UIImageJPEGRepresentation(image, 0.2)
                
                gifItem.imageURL = url
                gifItem.thumbImage = imageData
                gifItem.selectedFromPicker = false
                gifItem.imageID = self.getImageID(gifItem.imageURL)
                // gifItem.caption = "Test Caption"
                (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                
                // Add the feedItem to the feedArray so the user can see the item without having to quit and restart the application
                self.gifArray.append(gifItem)
                
                self.dismissViewControllerAnimated(true, completion: nil)
                
                // reload the collectionView data so the user can see the item without having to quit and restart the application
                self.collectionView.reloadData()
                
            } else {
                println("NAY")
            }
        })
    }
}