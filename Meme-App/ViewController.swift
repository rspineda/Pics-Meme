//
//  ViewController.swift
//  Meme-App
//
//  Created by Ronald Pineda on 21/10/21.
//

import UIKit

struct Meme {
    let topText: NSString
    let bottomText: NSString
    let originalImage: UIImage?
    let memedImage: UIImage?
}

class ViewController: UIViewController,  UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth:  -3.5
    ]
    
    // Delegates, centering and formatting text
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTextField(topTextField, text: "TOP")
        setupTextField(bottomTextField, text: "BOTTOM")
        self.shareButton.isEnabled = false
        
    }
    
    // Disable camera button if device doesn't have camera and keyboard appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardHideNotifications()
        }
    
    
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func setupTextField(_ textField: UITextField, text: String){
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    // Choose photo from album or camera
    @IBAction func pickImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if sender.tag == 0 {
            imagePicker.sourceType = .photoLibrary
        }else {
            imagePicker.sourceType = .camera
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Implementing delegate functionality of UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        self.shareButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        self.shareButton.isEnabled = false
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true;
        }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // Shifting the view up when keyboard is displayed
    @objc func keyboardWillShow(_ notification: Notification){
        view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    // subscribing to keyboard show notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    // subscribing to keyboard hide notifications
    func subscribeToKeyboardHideNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Shifting the view back down when keyboard is hidden
    @objc func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    func saveMeme()  {
        let meme = Meme(topText: self.topTextField.text! as NSString, bottomText: self.bottomTextField.text! as NSString, originalImage: self.imageView.image, memedImage: generateMeme())
        
    }
    
    func generateMeme() -> UIImage {
            self.topToolBar.isHidden = true
            self.bottomToolBar.isHidden = true
            UIGraphicsBeginImageContext(self.view.frame.size)
            view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
            let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            self.topToolBar.isHidden = false
            self.bottomToolBar.isHidden = false
            return memedImage
            
        }
    
    
        
    @IBAction func shareMeme(_ sender: Any) {
        
        var memeImage: UIImage
        memeImage = generateMeme()
        let vc = UIActivityViewController(activityItems: [memeImage], applicationActivities: [])
        vc.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:
                                            Bool, arrayReturnedItems: [Any]?, error: Error?) in
                                                if completed {
                                                    self.saveMeme()
                                                    return
                                                } 
                                            }
        present(vc, animated: true)
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
        self.imageView.image = nil
        
    }
    
    
}

