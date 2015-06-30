//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Ross Duris on 6/21/15.
//  Copyright (c) 2015 duris.io. All rights reserved.
//

import UIKit

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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
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
        //Create the meme
        var meme = Meme( topText:topTextField.text, bottomText:bottomTextField.text , image:
            chosenImageView.image!, memedImage:generateMemedImage() )
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        println(appDelegate.memes.count)
    }
    
    @IBAction func share() {
        self.resignKeyboards()
        let activityItem:UIImage! = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [activityItem], applicationActivities: nil)
        activityView.completionWithItemsHandler = activityComletionHandler
        presentViewController(activityView, animated: true, completion: nil)
    }
    

    
    func activityComletionHandler(activityType: String!,
        completed: Bool,
        returnedItems: [AnyObject]!,
        activityError: NSError!) {
            if activityError == nil && completed {
                self.save()
                self.dismissViewControllerAnimated(true, completion: nil)
                println("dissmissed activity view")
            }
    }
    
    func generateMemedImage() -> UIImage {
        
        //Hide toolbar and navbar
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.toolBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
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
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            if let meme = appDelegate.memes[memeIndex] as Meme! {
                meme.topText = topTextField.text
                meme.bottomText = bottomTextField.text
                meme.image = chosenImageView.image
                meme.memedImage = generateMemedImage()
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                println("Error editing meme")
            }
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

