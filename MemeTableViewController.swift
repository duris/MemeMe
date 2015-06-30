//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Ross Duris on 6/22/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    @IBOutlet weak var tabBar:UITabBarController!
    
    var memes = [Meme]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        loadMemes()
        self.tabBarController?.tabBar.hidden = false
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Setup cell data
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! MemeTableViewCell
        cell.topText.text = memes[indexPath.row].topText
        cell.bottomText.text = memes[indexPath.row].bottomText
        cell.memeImageView.image = memes[indexPath.row].memedImage
        
        //To Do: Create a thumbnail of the memedImage so it fits better in the cell
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let memeController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeViewController") as! MemeViewController
        
            //Launch the meme view with the selected meme
            if let meme = memes[indexPath.row] as Meme!{
                memeController.meme = meme
                memeController.index = indexPath.row
                self.navigationController?.pushViewController(memeController, animated: true)
            }
    }
    
    @IBAction func composeMeme() {
        //Launch the meme editor
        let memeEditor = self.storyboard!.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        let nav = UINavigationController(rootViewController: memeEditor)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
       
        var deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {
            (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            //Delete memes from data source
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.removeAtIndex(indexPath.row)
            self.memes.removeAtIndex(indexPath.row)
            
            //Delete row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        })
        
        return [deleteAction]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //Allow editing of cell
    }
    
    func loadMemes() {
        //Get meme data from the app delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        self.memes = appDelegate.memes
        self.tableView.reloadData()
    }
    

}
