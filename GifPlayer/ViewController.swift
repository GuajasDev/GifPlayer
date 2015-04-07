//
//  ViewController.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 10/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import Photos
import iAd

class ViewController: UIViewController,/* UIImagePickerControllerDelegate,*/ UINavigationControllerDelegate, ADBannerViewDelegate, UIScrollViewDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets
    
    @IBOutlet weak var iAdBanner: ADBannerView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: Variables
    
    var scrollView:UIScrollView!
    var imageCaptionLabel:UILabel!
    var gifArray:Array<GIFItem>!
    var gifArrayIndex:Int!
    var noDistractionView:Bool = false
    var pageViews:Array<UIImageView?> = []   // Images will be loaded when we need them so it must ba able to hable nil values
    
    // MARK: Constants
    let kSixth:CGFloat = 1.0/6.0
    let kFontSizePhone:CGFloat = 16.0
    let kFontSizePad:CGFloat = 20.0
    
    // MARK: - BODY
    
    // MARK: Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a text label
        let imageCaptionLabelFrame = CGRect(x: self.view.frame.size.width * self.kSixth * 0.5,
                                            y: UIApplication.sharedApplication().statusBarFrame.size.height,
                                            width: self.view.frame.width * self.kSixth * 5.0,
                                            height: 60.0)
        self.imageCaptionLabel = UILabel(frame: imageCaptionLabelFrame)
        self.imageCaptionLabel.textAlignment = NSTextAlignment.Center
        self.imageCaptionLabel.textColor = UIColor.whiteColor()
        self.imageCaptionLabel.numberOfLines = 0
        self.imageCaptionLabel.text = self.gifArray[self.gifArrayIndex].imageCaption
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.imageCaptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: self.kFontSizePad)
        } else {
            self.imageCaptionLabel.font = UIFont(name: "HelveticaNeue-Light", size: self.kFontSizePhone)
        }
        self.imageCaptionLabel.hidden = true
        self.view.addSubview(self.imageCaptionLabel)
        
        // Create a UIScrollView
        let pagesScrollViewFrame = CGRect(x: 0.0,y: 0.0,
                                          width: self.view.frame.size.width,
                                          height: self.view.frame.size.height - self.iAdBanner.frame.size.height)
        self.scrollView = UIScrollView(frame: pagesScrollViewFrame)
        self.updateScrolViewWithPage(self.gifArrayIndex)
        self.view.addSubview(self.scrollView)
        
        // Setup scroll view preferences
        self.scrollView.delegate = self
        self.scrollView.pagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        
        // Setup iAd banner preferences
        self.iAdBanner.delegate = self
        self.iAdBanner.alpha = 0.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Bring these two subviews to the front
        self.view.bringSubviewToFront(self.imageCaptionLabel)
        self.view.bringSubviewToFront(self.toolbar)
        
        // Fill the array of image views with nil values
        for _ in 0..<self.gifArray.count {
            self.pageViews.append(nil)
        }
        
        // Load the visible imageViews
        self.loadVisiblePages(false)
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
    
    func fetchImageAssetForItem(gifItem: GIFItem, onImageView imageView: UIImageView) {
        let fetchResults = PHAsset.fetchAssetsWithLocalIdentifiers([gifItem.imageID as NSString], options: nil)
        let asset:PHAsset = fetchResults.objectAtIndex(0) as PHAsset
        self.displayThisImageAsset(asset, onImageView: imageView)
        
    }
    
    func displayThisImageAsset(asset: PHAsset, onImageView imageView: UIImageView) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false
        
        // Get the imageData of the asset that was passed and animate it
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            self.animateImageWithData(NSData(data: imageData), onImageView: imageView)
        })
    }
    
    // MARK: IBActions
    
    @IBAction func userDidTapView(sender: UITapGestureRecognizer) {
        if self.noDistractionView == false {
            // Setup noDistractionView
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.backgroundColor = UIColor.blackColor()
                self.navigationController?.navigationBarHidden = true
                self.toolbar.hidden = true
                self.imageCaptionLabel.hidden = false
            })
            
            self.noDistractionView = true
        } else {
            // Set up detail view
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.backgroundColor = UIColor.whiteColor()
                self.navigationController?.navigationBarHidden = false
                self.toolbar.hidden = false
                self.imageCaptionLabel.hidden = true
            })
            
            self.noDistractionView = false
        }
    }
    
    
    @IBAction func editBarButtonItemTapped(sender: UIBarButtonItem) {
        
        // Get the gifItem
        let gifItem:GIFItem = self.getCurrentGifItem()
        
        // Create a text field and an alert view
        var inputTextField: UITextField?
        let editNameAlertView = UIAlertController(title: "Rename Image", message: "Choose a new name for your image.", preferredStyle: UIAlertControllerStyle.Alert)
        editNameAlertView.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        editNameAlertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            // The user tapped "OK"
            
            if inputTextField!.text != "" {
                // Change the name and save to CoreData
                gifItem.imageCaption = inputTextField!.text
                (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                
                // Change the title of the page to be the name of the image
                self.updateItemNameOnView(gifItem)
            }
        }))
        
        // Setup the text field.
        editNameAlertView.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            // If the imageCaption is the same as the original name then the text field has no text, just placeholder text. If the imageCaption has been edited then the text field has that text to begin with
            if gifItem.imageCaption == gifItem.imageName {
                textField.placeholder = "New Name"
            } else {
                textField.text = gifItem.imageCaption
            }
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            inputTextField = textField
        })
        
        presentViewController(editNameAlertView, animated: true, completion: nil)
        
    }
    
    @IBAction func actionBarButtonItemTapped(sender: UIBarButtonItem) {
//        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//        
//        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//            // The app is running on an iPad, so you have to wrap it in a UIPopOverController
//            var popOver: UIPopoverController = UIPopoverController(contentViewController: activityVC)
//            
//            // if your "share" button is a UIBarButtonItem
//            popOver.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
//            
//        } else {
//            self.presentViewController(activityVC, animated: true, completion: nil)
//        }
    }
    
    @IBAction func trashBarButtonItemTapped(sender: UIBarButtonItem) {
        
        // Create an alertController and add the actions
        var alertController = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image from GIF Player?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { (alertAction) -> Void in
            // The user tapped Delete
            
            // Create the deletedItem
            let entityDescription = NSEntityDescription.entityForName("DeletedItem", inManagedObjectContext: managedObjectContext!)
            let deletedItem = DeletedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
            
            // Save the localIdentifier of the GIFItem being deleted into a deletedItem
            deletedItem.imageID = self.getCurrentGifItem().imageID
            
            // Delete the GIFItem
            managedObjectContext?.deleteObject(self.getCurrentGifItem() as GIFItem)
            
            // Save to CoreData
            (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
            
            // Get the index of the GIFItem being deleted
            let pageWidth = self.view.frame.size.width
            var page = Int(floor((self.scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
            
            // Remove from arrays
            self.gifArray.removeAtIndex(page)
            self.pageViews.removeAtIndex(page)
            
            // Reset scroll view by deleting all of its subviews
            for view in self.scrollView.subviews {
                view.removeFromSuperview()
            }
            
            // Fill the array of image views with nil values
            for var i = 0; i < self.gifArray.count; i++ {
                self.pageViews[i] = nil
            }
            
            // Update scroll view. If the user deleted the last image, then show the previous to last, else show the next image
            if page >= self.gifArray.count { page = page - 1 }
            self.updateScrolViewWithPage(page)
            self.loadVisiblePages(true)
        }))
        
        // Present the alert view controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Swipe Image Helpers
    
    func loadVisiblePages(reload: Bool) {
        // First, determine which page is currently visible
        let pageWidth = self.view.frame.size.width
        let page = Int(floor((self.scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        if self.gifArray.count > 0 {
            // Change the title of the page to be the name of the image
            self.updateItemNameOnView(self.gifArray[page])
        } else {
            // *** User deleted all the gifItems, send back to collection view ***
        }
        
        // Work out which pages you want to load (the previous and next in this case)
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var i = 0; i < firstPage; ++i {
            self.purgePage(i)
        }
        
        // Load pages in the range
        for i in firstPage...lastPage {
            self.loadPage(i, reload: reload)
        }
        
        // Purge anything after the last page
        for var i = lastPage + 1; i < self.gifArray.count; ++i {
            self.purgePage(i)
        }
    }
    
    func loadPage(page: Int, reload: Bool) {
        // If page is not a valid index for the array, exit the function
        if page < 0 || page >= self.gifArray.count {
            return
        }
        
        // If pageView is not nil check it has already been created so check if its image needs to be reloaded. If so reload it, else leave it as it is
        if let pageView = self.pageViews[page] {
            if reload == true {
                self.fetchImageAssetForItem(self.gifArray[page], onImageView: pageView)
            }
        } else {
            // The 'page'th element in the pageViews array is nil, so create an imageView
            
            var frame = self.view.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = -self.iAdBanner.frame.height * 0.5
//            frame = CGRectInset(frame, 8.0, 0.0)

            let newPageView = UIImageView()
            newPageView.contentMode = UIViewContentMode.ScaleAspectFit
            newPageView.frame = frame
            
            // Add the imageView to the scrollView and display the image asset
            self.scrollView.addSubview(newPageView)
            self.fetchImageAssetForItem(self.gifArray[page], onImageView: newPageView)
            
            // Add the new imgeView to the pageViews array
            self.pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        // If page is not a valid index for the array, exit the function
        if page < 0 || page >= self.gifArray.count {
            return
        }
        
        // Remove a page from the scroll view and reset the container to nil
        if let pageView = self.pageViews[page] {
            pageView.removeFromSuperview()
            self.pageViews[page] = nil
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on the screen
        self.loadVisiblePages(false)
    }
    
    // MARK: General Helpers
    
    func getCurrentGifItem() -> GIFItem {
        // Returns the GIFItem currently being displayed
        
        let pageWidth = self.view.frame.size.width
        let page = Int(floor((self.scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        return self.gifArray[page]
    }
    
    func updateScrolViewWithPage(page: Int) {
        // Sets the content size and offset of the scroll view depending on how many GIFItems there are and which one needs to be displayed
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(self.gifArray.count),
                                             height: self.scrollView.frame.size.height)
        var offsetX = self.scrollView.frame.size.width * CGFloat(page)
        self.scrollView.setContentOffset(CGPoint(x: offsetX, y: self.scrollView.contentOffset.y), animated: true)
    }
    
    func updateItemNameOnView(gifItem: GIFItem) {
        // Change the title of the page and text in the label to be the name of the image
        
        self.title = gifItem.imageCaption
        self.imageCaptionLabel.text = gifItem.imageCaption
    }
    
    func animateImageWithData(imageData: NSData, onImageView imageView: UIImageView) {
        // Animates the gif image using its imageData and the UIImage+animatedGIF category
        
        var testImage = UIImage.animatedImageWithAnimatedGIFData(imageData)
        imageView.animationImages = testImage.images
        imageView.animationDuration = testImage.duration
        imageView.animationRepeatCount = 0
        /* If I want the animation to stop in the last frame, set 'animationRepeatCount' to 1 and uncomment this
        self.gifImageView.image = testImage.images!.last as! UIImage! */
        imageView.startAnimating()
    }
    
    // MARK: Terminating
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        // Called when the back button is pressed so stop animating
        for index in self.pageViews {
            index?.stopAnimating()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Called before the view is dismissed
        self.navigationController?.toolbarHidden = true
    }
}

// MARK: - PHAsset Class Extension

// Fetches an asset using a URL
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