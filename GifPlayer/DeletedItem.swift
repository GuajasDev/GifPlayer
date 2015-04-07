//
//  DeletedItem.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 4/7/15.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import Foundation
import CoreData

@objc(DeletedItem)
class DeletedItem: NSManagedObject {

    @NSManaged var imageID: String

}
