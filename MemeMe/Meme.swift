//
//  Meme.swift
//  MemeMe
//
//  Created by Ross Duris on 6/21/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import Foundation
import UIKit

class Meme: NSObject{
    var topText:String!
    var bottomText:String!
    var image:UIImage!
    var memedImage:UIImage!
    
    init(topText:String, bottomText:String, image:UIImage, memedImage:UIImage ){
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
}