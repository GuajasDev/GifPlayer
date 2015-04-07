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
import iAd

// MARK: - Universal Constants

// Get the managedObjectContext and the singleton instance of the AppDelegate
let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
let appDelegate:AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)

// MARK: Class

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ADBannerViewDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var iAdBanner: ADBannerView!
    
    // MARK: Variables
    
    // We use 'AnyObject' because when we 'executeFetchRequest' in viewDidLoad, we get an array with AnyObject instances. We are doing the fetch request manually rather than using the NSFetchResultsController manage this for us as in TaskIt mainly to practice both ways
    var gifArray:[AnyObject] = []
    var deletedArray:[AnyObject] = []
    
    var gifArrayIndex:Int!
    var loadingImageView = UIImageView()
    var updatingLabel = UILabel()
    var testButton = UIButton()
    
    // MARK: Constants
    
    let loadingView = UIView()
    
    // MARK: - BODY
    
    // MARK: Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup the collectionView
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        // Setup the iAdBanner
        self.iAdBanner.delegate = self
        self.iAdBanner.alpha = 0.0
        
        // Setup the navigationController
        self.navigationController?.toolbarHidden = true
        self.title = "GIF Player"
        
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
        
        // Create the loading view
        self.loadingView.frame = self.view.frame
        
        self.setupLoadingScreen()
        self.shouldBeLoading(true)
        
        // Fetch the items from the photo library
        self.fetchGifItemsFromLibrary()
        self.shouldBeLoading(false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // We are doing the fetch request manually rather than using the NSFetchResultsController manage this for us as in TaskIt mainly to practice both ways
        // Request all the GIFItems and DeletedItems that are saved
        let gifRequest = NSFetchRequest(entityName: "GIFItem")
        let deletedRequest = NSFetchRequest(entityName: "DeletedItem")
        
        // Get access to the context from the AppDelegate
        let context:NSManagedObjectContext = appDelegate.managedObjectContext!
        
        // Execute the fetch request and save the AnyObject instances
        self.gifArray = context.executeFetchRequest(gifRequest, error: nil)!
        self.deletedArray = context.executeFetchRequest(deletedRequest, error: nil)!
        
        // Check if the collection view has already been set up, if it has reload the data
        if self.collectionView != nil {
            self.collectionView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Prepare for Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toMainVC" {
            // Going to MainViewController
            
            var mainVC:ViewController = segue.destinationViewController as ViewController
            mainVC.gifArray = sender as Array<GIFItem>
            mainVC.gifArrayIndex = self.gifArrayIndex
            self.navigationController?.toolbarHidden = true
        }
    }
    
    // MARK: IBActions
    
    @IBAction func addBarButtonItemPressed(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            // The photo library is available
            
            // Setup the imagePickerController
            var photoLibraryController = UIImagePickerController()
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            // Specify the media types for the media controller, in this case it is media data
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            photoLibraryController.mediaTypes = mediaTypes
            photoLibraryController.allowsEditing = false
            
            // Present the photo library controller to the screen
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
            
        } else {
            // The photo library is not available, present an alarm
            
            var alertController = UIAlertController(title: "Alert", message: "Your device does not support the photo library. Please check in Settings if it is enabled for this application", preferredStyle: UIAlertControllerStyle.Alert)
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
        
        // Setup the cells
        let thisItem = self.gifArray[indexPath.row] as GIFItem
        let cell:GIFCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("gifCell", forIndexPath: indexPath) as GIFCollectionViewCell
        cell.imageView.image = UIImage(data: thisItem.thumbImage)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Choose the cell size depending on the device
        
        var size:CGSize
        
        if self.view.frame.width == 320 {
            // iPhone 5/5C/5S
            let width = (self.view.frame.width + 5) / 4
            size = CGSizeMake(width, width)
        } else if self.view.frame.width == 375 {
            // iPhone 6
            let width = (self.view.frame.width + 5) / 4
            size = CGSizeMake(width, width)
        } else if self.view.frame.width == 414 {
            // iPhone 6 Plus
            let width = (self.view.frame.width - 4) / 5
            size = CGSizeMake(width, width)
        } else {
            // iPad
            let width = (self.view.frame.width - 6) / 6
            size = CGSizeMake(width, width)
        }
        
        return size
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Cell was tapped so save the index of the tapped cell and perform segue to MainVC
        self.gifArrayIndex = indexPath.row
        self.performSegueWithIdentifier("toMainVC", sender: self.gifArray)
    }
    
    // MARK: UIImagePickerControllerDelegaate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        // Get the url of the image that was chosen
        let url:NSURL = info["UIImagePickerControllerReferenceURL"] as NSURL
        
        // Create a PHAsset using the image url and save it. The saveGIFImageAsset checks if the image has already been saved or not
        let gifImage:PHAsset = PHAsset.fetchAssetWithALAssetURL(url)!
        self.saveGIFImageAsset(gifImage, fromPicker: true)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: ADBannerViewDelegate
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.iAdBanner.alpha = 1.0
        })
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        println("CollectionVC's iAd Error: \(error)")
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.iAdBanner.alpha = 0.0
        })
    }
    
    // MARK: Helpers
    
    func getImageName(url: String) -> String {
        // URL is of the form 'File: ///Users/diegoguajardo/Library/Developer/CoreSimulator/Devices/34A6CCB2-663A-4598-A6AD-998CFF817E56/data/Media/DCIM/100APPLE/IMG_0008.GIF', so the last 12 characters are the name of the image
        var startOfString = advance(url.endIndex, -12)
        let endOfString = url.endIndex
        let range = Range<String.Index>(start:startOfString, end:endOfString)
        let localNameFragment = url.substringWithRange(range)
        return localNameFragment
    }
    
    func fetchGifItemsFromLibrary() {
        
        // *** Start Loading ***
        
        var asset = PHAsset()
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            // Loop through the photo library and fetch all the images
            var fetchResult = PHFetchResult()
            fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
            
            // For all the fetched images, save the ones that are GIFs (checked performed in 'saveGIFImageAsset')
            for var indx:Int = 0; indx < fetchResult.count; indx++ {
                asset = fetchResult[indx] as PHAsset
                self.saveGIFImageAsset(asset, fromPicker: false)
            }
            
            }, completionHandler: { (success, error) -> Void in
                if error != nil { println("Error \(error)") }
        })
    }
    
    func saveGIFImageAsset(asset: PHAsset, fromPicker: Bool) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false
        
        // Get the data of the asset that was passed
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            
            // Get the url and the name
            let url = (info["PHImageFileURLKey"] as NSURL).absoluteString!
            let imageName = self.getImageName(url)
            
            // Initialise a boolean to check if the image already exists in CoreData and another to check if the user has previously deleted the asset
            var existsAlready = false
            var previouslyDeleted = false
            
            // Loop through all the saved assets. If the name of the asset that was passed equals one that is already saved then it exists already and it is not saved again
            for var i = 0; i < self.gifArray.count; i++ {
                if asset.localIdentifier == (self.gifArray[i] as GIFItem).imageID {
                    existsAlready = true
                }
            }
            
            // Loop through the identifiers of the assets that have previously been deleted by the user. If the asset being added has a local identifier equal to one that is saved as a DeletedItem check if it was selected using UIImagePicker, if it was then save to CoreData, if it was not then do not save.
            for var i = 0; i < self.deletedArray.count; i++ {
                if asset.localIdentifier == (self.deletedArray[i] as DeletedItem).imageID {
                    if fromPicker == false {
                        previouslyDeleted = true    // If set to true then asset will not be saved to CoreData
                    } else {
                        previouslyDeleted = false    // If set to false then asset will be saved to CoreData
                        
                        // Delete the DeletedItem from CoreData since the user has manually re-added the previously deleted asset
                        managedObjectContext?.deleteObject(self.deletedArray[i] as DeletedItem)
                        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                        self.deletedArray.removeAtIndex(i)
                    }
                }
            }
            
            // If the asset does not exist in Core Data and has not previously been deleted, save it
            if existsAlready == false {
                if previouslyDeleted == false {
                    if url.rangeOfString(".GIF") != nil {
                        // The url contains ".GIF", so it is a GIF image
                        
                        // Create an entityDescription
                        let entityDescription = NSEntityDescription.entityForName("GIFItem", inManagedObjectContext: managedObjectContext!)
                        
                        // Create the GIFItem
                        let gifItem = GIFItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                        
                        // Save the required information
                        gifItem.imageID = asset.localIdentifier
                        gifItem.thumbImage = imageData
                        gifItem.date = asset.creationDate
                        gifItem.imageName = imageName
                        gifItem.imageCaption = imageName
                        
                        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                        
                        // Add the gifItem to the gifArray and reload the collectionView data so the user can see the item without having to quit and restart the application
                        self.gifArray.append(gifItem)
                        self.collectionView.reloadData()
                        
                    } else { println("Not a GIF") }
                    
                } else { println("Previously Deleted") }
                
            } else { println("Exists") }

        })
    }
    
    func setupLoadingScreen() {
        
        // Only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = self.view.bounds
            self.loadingView.addSubview(blurEffectView)
            
            // Add auto layout constraints so that the blur fills the screen upon rotating device
            blurEffectView.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.loadingView.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.loadingView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
            self.loadingView.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.loadingView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
            self.loadingView.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.loadingView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
            self.loadingView.addConstraint(NSLayoutConstraint(item: blurEffectView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.loadingView, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        } else {
            self.loadingView.backgroundColor = UIColor.blackColor()
        }
        
        // Add the view on top of the navigation controller
        self.navigationController?.view.addSubview(self.loadingView)
        
        // Create the label
        self.updatingLabel.font = UIFont(name: "HelveticaNeue-Light", size: 24)
        self.updatingLabel.textColor = UIColor.whiteColor()
        self.updatingLabel.text = "Updating Library..."
        self.updatingLabel.sizeToFit()
        
        // Create the imageView
        self.loadingImageView.image = UIImage(named: "Loading 1")
        self.loadingImageView.sizeToFit()
        
        // Position the label and imageView
        var yPos = self.updatingLabel.frame.size.height + 22 + self.loadingImageView.frame.size.height
        self.updatingLabel.frame.origin = CGPointMake(self.view.frame.size.width * 0.5 - self.updatingLabel.frame.size.width * 0.5,
                                                      self.view.frame.size.height * 0.5 - yPos * 0.5)
        self.loadingImageView.frame.origin = CGPointMake(self.view.frame.size.width * 0.5 - self.loadingImageView.frame.size.width * 0.5,
                                                         self.updatingLabel.frame.origin.y + self.updatingLabel.frame.size.height + 22)
        
        // Add them to the view
        self.loadingView.addSubview(updatingLabel)
        self.loadingView.addSubview(loadingImageView)
        
        // Setup the loading animation
        var loadingImages:Array<UIImage> = []
        for (var i = 1; i < 10; i++) {
            loadingImages.append(UIImage(named: "Loading \(i)")!)
        }
        self.loadingImageView.animationImages = loadingImages
        self.loadingImageView.animationDuration = 0.45
        self.loadingImageView.animationRepeatCount = 0
        
//        self.testButton.frame = CGRectMake(150, 400, 50, 50)
//        self.testButton.backgroundColor = UIColor.redColor()
//        self.testButton.addTarget(self, action: "changeLoadingView", forControlEvents: UIControlEvents.TouchUpInside)
//        self.loadingView.addSubview(self.testButton)
        
        self.loadingView.hidden = true
    }
    
    func shouldBeLoading(isLoading: Bool) {
        if isLoading == true {
            self.loadingView.hidden = false
            self.loadingImageView.startAnimating()
        } else {
            self.loadingView.hidden = true
            self.loadingImageView.stopAnimating()
        }
    }
}












