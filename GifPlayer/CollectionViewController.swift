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
        var cell:GIFCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("giffCell", forIndexPath: indexPath) as GIFCollectionViewCell
        
        // The row property refers to the cell (ie row 0 is the first cell, row 1 is the second cell, etc...) not the actual rows of cells
        let thisItem = self.gifArray[indexPath.row] as GIFItem
        
        cell.imageView.image = UIImage(data: thisItem.image)
//        cell.captionLabel.text = thisItem.caption
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let thisItem = self.gifArray[indexPath.row] as GIFItem
        
        // Create a filterViewController
        var mainVC = ViewController()
        mainVC.thisGIFItem = thisItem
        self.navigationController?.pushViewController(mainVC, animated: false)
    }
    
    // MARK: UIImagePickerControllerDelegaate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        // info is a dictionary that is passed in the function, we are using the 'UIImagePickerControllerOriginalImage' key to get back the value of the (original) UIImage we want to display
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        
        // Save the image to CoreData. The image will be converted into a data representation (NSData instance, which is a binary representation) of the UIImage instance
        // ********** DONT SAVE THE IMAGE DATA, SAVE THE URL **********
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        // Get the managedObjectContext
        let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
        
        // Create an entityDescription
        let entityDescription = NSEntityDescription.entityForName("GIFItem", inManagedObjectContext: managedObjectContext!)
        
        // Create the FeedItem
        let gifItem = GIFItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
        
        // ********** DONT SAVE THE IMAGE DATA, SAVE THE URL **********
        gifItem.image = imageData
//        gifItem.caption = "Test Caption"
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        // Add the feedItem to the feedArray so the user can see the item without having to quit and restart the application
        self.gifArray.append(gifItem)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // reload the collectionView data so the user can see the item without having to quit and restart the application
        self.collectionView.reloadData()
    }
}