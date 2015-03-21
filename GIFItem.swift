//
//  GIFItem.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 20/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import Foundation
import CoreData

@objc(GIFItem)
class GIFItem: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var imageID: String
    @NSManaged var imageURL: String
    @NSManaged var selectedFromPicker: NSNumber
    @NSManaged var thumbImage: NSData
    @NSManaged var imageCaption: String
    @NSManaged var imageName: String

}
