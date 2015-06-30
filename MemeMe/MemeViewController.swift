//
//  MemeViewController.swift
//  MemeMe
//
//  Created by Ross Duris on 6/21/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

class MemeViewController: UIViewController {
    
    @IBOutlet weak var memeImageView:UIImageView!
    var meme:Meme!
    var index:Int!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        if let image = meme.memedImage {
            memeImageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func share() {
        if let image = meme.memedImage {
            let activityItem:UIImage! = image
            let activityView = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
            //activityView.completionWithItemsHandler = activityComletionHandler
            presentViewController(activityView, animated: true, completion: nil)
        }
    }


    @IBAction func editMeme(meme:Meme) {
        //Launch the editor with the current meme
        let memeEditor = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        if let meme = self.meme as Meme!{
            memeEditor.meme = meme
            memeEditor.editingExisting = true
            memeEditor.index = index
        }
        let nav = UINavigationController(rootViewController: memeEditor)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    @IBAction func deleteMeme(meme:Meme) {
        let alertController = UIAlertController(title: nil, message: "This meme will be deleted. This action cannot be undone.", preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        alertController.addAction(cancelAction)

        let destroyAction = UIAlertAction(title: "Delete Meme", style: .Destructive) { (action) in
            self.confirmDelete()
        }
        alertController.addAction(destroyAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func confirmDelete(){
        //Delete meme at its index
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.removeAtIndex(index)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
        
}
