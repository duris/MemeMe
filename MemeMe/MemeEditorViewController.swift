//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Ross Duris on 6/21/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit
import CoreData

class MemeEditorViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var chosenImageView:UIImageView!
    @IBOutlet weak var cameraButton:UIBarButtonItem!
    @IBOutlet weak var cancelButton:UIBarButtonItem!
    @IBOutlet weak var topTextField:UITextField!
    @IBOutlet weak var bottomTextField:UITextField!
    @IBOutlet weak var toolBar:UIToolbar!
    @IBOutlet weak var shareButton:UIBarButtonItem!
    @IBOutlet weak var doneButton:UIBarButtonItem!
    var index:Int!
    var memedImage:UIImage!
    var meme:Meme!
    var memes = [Meme]()
    var editingExisting = false as Bool
    let topText = "TOP"
    let bottomText = "BOTTOM"
    let memeTextAttributes = [
        NSFontAttributeName : UIFont(name: "Impact", size: 40)!,
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSStrokeWidthAttributeName: -3.0
    ]

    override func viewDidLoad() {
        super.viewDidLoad()        
        
        //Disable the camera button if the device does not have a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //Setup the textfields
        setupMemeTextField(topTextField)
        setupMemeTextField(bottomTextField)
    }

    override func viewWillAppear(animated: Bool) {
        
        //Disable the share button if there's no chosen image
        if chosenImageView.image == nil {
            shareButton.enabled = false
        } else {
            shareButton.enabled = true
        }
        
        //Subscribe to the keyboard notifications
        self.subscribeToKeyboardNotifications()
        
        //Disable and hide the done button if not editing a previous meme
        if editingExisting == false {
            doneButton.enabled = false
            doneButton.setBackgroundImage(UIImage(named: "blank"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
            doneButton.title = ""
        } else {
            doneButton.enabled = true
            doneButton.setBackgroundImage(nil, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
            doneButton.title = "Done"
        }
        
        //Load meme data if it exitsts
        if meme != nil {
            chosenImageView.image = meme.image
            topTextField.text = meme.topText
            bottomTextField.text = meme.bottomText
            shareButton.enabled = true
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Unsubscribe to the keyboard notifications
        self.unsubscribeToKeyboardNotifications()
    }
    
    func setupMemeTextField(textField:UITextField) {
        //Setup the text field's to the desired format
        textField.defaultTextAttributes = memeTextAttributes
        textField.delegate = self
        textField.center = view.center
        textField.contentVerticalAlignment = .Center
        textField.textAlignment = .Center
        textField.autocapitalizationType = .AllCharacters
        
        //Reset the text fields if they're empty
        if textField == topTextField {
            if textField.text == "" {
                textField.text = topText
            }
        } else {
            if textField.text == "" {
                textField.text = bottomText
            }
        }
    }
    
    @IBAction func pickAnImageFromLibrary(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.chosenImageView.image = image
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == topText || textField.text == bottomText {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        setupMemeTextField(topTextField)
        setupMemeTextField(bottomTextField)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if topTextField.text == "" {
            topTextField.text = topText
        }
        if bottomTextField.text == "" {
            self.bottomTextField.text = bottomText
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification:NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue //of cgrect
        return keyboardSize.CGRectValue().height
    }
    
    func save() {
        print("hello")
        let dictionary: [String : AnyObject] = [
            Meme.Keys.TopText : topTextField.text!,
            Meme.Keys.BottomText : bottomTextField.text!,
            Meme.Keys.ImagePath : chosenImageView.image!,
            Meme.Keys.MemedImagePath : generateMemedImage()
        ]
        
        // Now we create a new Meme, using the shared Context
        let memeToBeAdded = Meme(dictionary: dictionary, context: sharedContext)
        
        
        self.memes.append(memeToBeAdded)
        
        print(memes.count)
        
        // Finally we save the shared context, using the convenience method in
        // The CoreDataStackManager
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    @IBAction func share() {
        self.resignKeyboards()
        let activityItem:UIImage! = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        self.save()
       // activityView.completionWithItemsHandler = doneSharingHandler
        presentViewController(activityView, animated: true, completion: nil)
    }
    
    
    func doneSharingHandler(activityType: String!, completed: Bool, returnedItems: [AnyObject]!, error: NSError!) {
        // Return if cancelled
        if (!completed) {
            return
        }
        
        // If here, log which activity occurred
       // println("Shared video activity: \(activityType)")
    }

    
    func activityComletionHandler(activityType: String!, completed: Bool, returnedItems: [AnyObject]!, activityError: NSError!) {
            if activityError == nil && completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
                print("dissmissed activity view")
            } else {
                print(activityError)
            }
    }
    
    func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.toolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 4.0)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show toolbar and navbar
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.toolBar.hidden = false
        
        return memedImage
    }
    
    @IBAction func doneEditing() {
        
        self.resignKeyboards()
        
        //Save the changes to the meme that has been edited
        if let memeIndex = index as Int! {
            let memes = fetchAllMemes()
            if let meme = memes[memeIndex] as Meme! {
                meme.topText = topTextField.text
                meme.bottomText = bottomTextField.text
                meme.image = chosenImageView.image
                meme.memedImage = generateMemedImage()
                self.dismissViewControllerAnimated(true, completion: nil)
                CoreDataStackManager.sharedInstance().saveContext()
            } else {
                print("Error editing meme")
            }
        }
    }

    
    /**
     * This is the convenience method for fetching all persistent memes.
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
    
    @IBAction func cancelMeme() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func resignKeyboards() {
        //Hide the keyboards & prevent the insertion cursor from rendering
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
    }
}

