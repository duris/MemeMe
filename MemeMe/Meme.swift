//
//  Meme.swift
//  MemeMe
//
//  Created by Ross Duris on 6/21/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Meme: NSManagedObject{
    
    struct Keys {
        static let TopText = "top_text"
        static let BottomText = "bottom_text"
        static let ImagePath = "image_path"
        static let MemedImagePath = "memed_image_path"
    }
    
    @NSManaged var topText:String!
    @NSManaged var bottomText:String!
    @NSManaged var image:UIImage!
    @NSManaged var memedImage:UIImage!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entityForName("Meme", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Dictionary
        topText = dictionary[Keys.TopText] as! String
        bottomText = dictionary[Keys.BottomText] as! String
        image = dictionary[Keys.ImagePath] as? UIImage
        memedImage = dictionary[Keys.MemedImagePath] as? UIImage
    }
    
    
}