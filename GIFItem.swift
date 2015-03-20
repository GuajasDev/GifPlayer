//
//  GIFItem.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 3/20/15.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import Foundation
import CoreData

@objc(GIFItem)
class GIFItem: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var imageURL: String
    @NSManaged var selectedFromPicker: NSNumber
    @NSManaged var thumbImage: NSData
    @NSManaged var imageID: String

}
