//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Ross Duris on 6/22/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

let reuseIdentifier = "MemeCollectionCell"

class MemeCollectionViewController: UICollectionViewController {
    
    var memes = [Meme]()

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    override func viewWillAppear(animated: Bool) {
        loadMemes()
        self.tabBarController?.tabBar.hidden = false
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.memes.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
    
        // Configure the cell
        let meme = self.memes[indexPath.row]
        cell.memedImageView?.image = meme.memedImage
    
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let memeController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeViewController") as! MemeViewController
        
        
        if let meme = memes[indexPath.item] as Meme!{
            memeController.meme = meme
            memeController.index = indexPath.item
            self.navigationController?.pushViewController(memeController, animated: true)
        }
    
    }

    @IBAction func composeMeme() {
        let memeEditor = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        let nav = UINavigationController(rootViewController: memeEditor)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    func loadMemes() {
        self.collectionView?.reloadData()
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.memes = appDelegate.memes
    }
    

}
