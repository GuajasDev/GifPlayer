//
//  ViewController.swift
//  GifPlayer
//
//  Created by Diego Guajardo on 10/03/2015.
//  Copyright (c) 2015 GuajasDev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var testImage = UIImage.animatedImageWithAnimatedGIFData(
            NSData.dataWithContentsOfURL(url))
        self.dataImageView.animationImages = testImage.images
        self.dataImageView.animationDuration = testImage.duration
        self.dataImageView.animationRepeatCount = 1
        self.dataImageView.image = testImage.images.lastObject
        self.dataImageView.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

