//
//  GIFItem.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 13/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import Foundation
import CoreData

@objc (GIFItem)    // We add this so the FeedItem class can interact with Objective-C, just in case we need it
class GIFItem: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var image: NSData
    @NSManaged var isPlaying: NSNumber

}
