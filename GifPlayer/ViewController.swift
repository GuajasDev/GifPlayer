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

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ADBannerViewDelegate, UIScrollViewDelegate {
    
    // MARK: - PROPERTIES
    
    // MARK: IBOutlets
    
//    @IBOutlet weak var gifImageView: UIImageView!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iAdBanner: ADBannerView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: Variables
    
//    var thisGIFItem:GIFItem!
    var navigationBarHeight:CGFloat!
    var toolBarHeight:CGFloat!
    var offsetX:CGFloat = 0.0 // Used to know if the user scrolls right or left
    var gifArray:Array<GIFItem>!
    var gifArrayIndex:Int!
    var noDistractionView:Bool!
    var pageViews:Array<UIImageView?> = []   // Images will be loaded when we need them so it must ba able to hable nil values
    
    // MARK: - BODY
    
    // MARK: Initialisers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.iAdBanner.delegate = self
        self.iAdBanner.alpha = 0.0
        
        self.navigationBarHeight = self.navigationController!.navigationBar.frame.size.height
        self.toolBarHeight = self.navigationController!.toolbar.frame.size.height
        
//        self.titleLabel.hidden = true
        self.noDistractionView = false
        
        println("viewDidLoad finished")
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Step 1
        let pageCount = self.gifArray.count
        
        // Step 3
        for _ in 0..<self.gifArray.count {
            self.pageViews.append(nil)
        }
        
        // Step 2
        self.pageControl.currentPage = 0
        self.pageControl.numberOfPages = self.gifArray.count
        self.pageControl.hidden = true
        self.setupImageView(self.gifArray[self.gifArrayIndex])
        
        // Step 4
        let pagesScrollViewFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.iAdBanner.frame.size.height)
        self.scrollView.contentSize = CGSize(width: pagesScrollViewFrame.size.width * CGFloat(self.gifArray.count),
                                             height: pagesScrollViewFrame.size.height
                                                     - self.navigationBarHeight
                                                     - UIApplication.sharedApplication().statusBarFrame.size.height)

        self.offsetX = pagesScrollViewFrame.size.width * CGFloat(self.gifArrayIndex)
        self.scrollView.setContentOffset(CGPoint(x: self.offsetX, y: self.scrollView.contentOffset.y), animated: false)
        
        // Step 5
        self.loadVisiblePages(startingWithIndex: self.gifArrayIndex)
        
        println("viewWillAppear finished")
        
    }
    
    override func viewDidLayoutSubviews() {
        
        // Setup Scroll View
        self.scrollView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height - self.iAdBanner.frame.size.height)
        self.scrollView.setContentOffset(CGPoint(x: self.offsetX, y: self.scrollView.contentOffset.y), animated: false)
        
//        //  Step 1
//        let pageCount = self.gifArray.count
//        
//        // Step 4
//        let pagesScrollViewSize = self.scrollView.frame.size
//        self.scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(self.gifArray.count),
//            height: pagesScrollViewSize.height
//                - self.navigationBarHeight
//                - UIApplication.sharedApplication().statusBarFrame.size.height)
//
//        // Step 5
//        self.loadVisiblePages(startingWithIndex: self.gifArrayIndex)
        
        println("viewDidLayoutSubviews finished")
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
    
    func fetchImageAssetForItem(gifItem: GIFItem, onImageView imageView: UIImageView, startAnimating animating: Bool) {
        let fetchResults = PHAsset.fetchAssetsWithLocalIdentifiers([gifItem.imageID as NSString], options: nil)
        let asset:PHAsset = fetchResults.objectAtIndex(0) as PHAsset
        self.displayThisImageAsset(asset, onImageView: imageView, startAnimating: animating)
        
    }
    
    func displayThisImageAsset(asset: PHAsset, onImageView imageView: UIImageView, startAnimating animating: Bool) {
        let imageRequestOptions = PHImageRequestOptions()
        // When set to false it loads a low-quality image first if there is no high res available in the cache and then runs the completion handler from 'requestImageDataForAsset' again when it can retrieve the high res image. It is faster
        imageRequestOptions.synchronous = false
        
        // Get the url of the asset that was passed, if its url is the same as the urlin thisGIFItem then display it and animate it
        PHImageManager.defaultManager().requestImageDataForAsset(asset, options: imageRequestOptions, resultHandler: { (imageData, dataUTI, orientation, info) -> Void in
            self.animateImageWithData(NSData(data: imageData), onImageView: imageView, startAnimating: animating)
            
            
//            let url = (info["PHImageFileURLKey"] as NSURL).absoluteString!
//            if url == self.thisGIFItem.imageURL {
//                self.animateImageWithData(NSData(data: imageData))
//            }
        })
    }
    
    // MARK: IBActions
    
    @IBAction func userDidTapView(sender: UITapGestureRecognizer) {
//        self.setupImageView(self.gifArray[self.gifArrayIndex + 1])
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
            // Code To Delete Image
            
            // Get the managedObjectContext
            let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
            
            managedObjectContext?.deleteObject(self.gifArray[self.gifArrayIndex] as GIFItem)
            
            (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
            
            self.gifArray.removeAtIndex(self.gifArrayIndex)
            
            self.setupImageView(self.gifArray[self.gifArrayIndex])
        }))
        
        // Present the alert view controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    func setupImageView(thisGifItem: GIFItem) {
//        self.fetchImageAssetForItem(thisGifItem)
        self.title = thisGifItem.imageCaption
//        self.titleLabel.text = thisGifItem.imageCaption
    }
    
    func animateImageWithData(imageData: NSData, onImageView imageView: UIImageView, startAnimating animating: Bool) {
        var testImage = UIImage.animatedImageWithAnimatedGIFData(imageData)
        imageView.animationImages = testImage.images
        imageView.animationDuration = testImage.duration
        imageView.animationRepeatCount = 0
        /* If I want the animation to stop in the last frame, set 'animationRepeatCount' to 1 and uncomment this
        self.gifImageView.image = testImage.images!.last as! UIImage! */
        if Bool(animating) { imageView.startAnimating() }
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= self.gifArray.count {
            return
        }
        
        // Step 1
        if let pageView = self.pageViews[page] {
            // Do Nothing. The view is already loaded
        } else {
            // Step 2
            var frame = self.view.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = UIApplication.sharedApplication().statusBarFrame.size.height - (self.toolBarHeight + self.iAdBanner.frame.size.height)
//            frame = CGRectInset(frame, 10.0, 0.0)
            
            //Step 3
            let newPageView = UIImageView()
            newPageView.contentMode = UIViewContentMode.ScaleAspectFit
            newPageView.frame = frame
            self.scrollView.addSubview(newPageView)
            self.fetchImageAssetForItem(self.gifArray[page], onImageView: newPageView, startAnimating: true)
            
            // Step 4
            self.pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= self.gifArray.count {
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = self.pageViews[page] {
            pageView.removeFromSuperview()
            self.pageViews[page] = nil
        }
    }
    
    func loadVisiblePages(startingWithIndex index: Int) {
        // First, determine which page is currently visible
        let pageWidth = self.view.frame.size.width
        let page = Int(floor((self.scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        self.pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var i = 0; i < firstPage; ++i {
            self.purgePage(i)
        }
        
        // Load pages in our range
        for i in firstPage...lastPage {
            self.loadPage(i)
        }
        
        // Purge anything after the last page
        for var i = lastPage + 1; i < self.gifArray.count; ++i {
            self.purgePage(i)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on the screen
        
//        if self.lastContentOffset > scrollView.contentOffset.x {
//            // Scrolled right
//            if self.gifArrayIndex > 0 {
//                self.gifArrayIndex = self.gifArrayIndex - 1
//            }
//        } else if self.lastContentOffset < scrollView.contentOffset.x {
//            // Scrolled left
//            if self.gifArrayIndex < self.gifArray.count - 1 {
//                self.gifArrayIndex = self.gifArrayIndex + 1
//            }
//        }
        
        // *** Check why when last index selected the offset moves back ***
        println(self.scrollView.contentOffset.x)
        
//        self.lastContentOffset = scrollView.contentOffset.x
        
        self.loadVisiblePages(startingWithIndex: self.gifArrayIndex)
    }
    
    // MARK: Terminating
    
    override func viewWillDisappear(animated: Bool) {
        // Called before the view is dismissed
//        self.gifImageView.stopAnimating()
        self.navigationController?.toolbarHidden = true
        for index in self.pageViews {
            index?.stopAnimating()
        }
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

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext() as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}