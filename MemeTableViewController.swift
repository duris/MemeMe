//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Ross Duris on 6/22/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import CoreData

class MemeTableViewController: UITableViewController {
    
    @IBOutlet weak var tabBar:UITabBarController!
    
    var memes = [Meme]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        memes = fetchAllMemes()
        tableView.reloadData()
        navigationItem.leftBarButtonItem = editButtonItem()
        self.tabBarController?.tabBar.hidden = false
        tableView.editing = false
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Setup cell data
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! MemeTableViewCell
        let meme = memes[indexPath.row]
        cell.topText.text = meme.topText as String
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
    

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //Allow editing of cell
        switch (editingStyle) {
        case .Delete:
            let meme = self.memes[indexPath.row]
            
            self.memes.removeAtIndex(indexPath.row)
            
            //Delete row
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            sharedContext.deleteObject(meme)
            CoreDataStackManager.sharedInstance().saveContext()
        default:
            break
        }
    }
    
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    
    /**
     * This is the convenience method for fetching all persistent Memes.
     *
     * The method creates a "Fetch Request" and then executes the request on
     * the shared context.
     */
    func fetchAllMemes() -> [Meme] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "Meme")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Meme]
        } catch  let error as NSError {
            print("Error in fetchAllMemes(): \(error)")
            return [Meme]()
        }
    }
    

}
