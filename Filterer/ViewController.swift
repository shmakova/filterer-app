//
//  ViewController.swift
//  Filterer
//
//  Created by Anastasia Shmakova on 18.01.16.
//  Copyright © 2016 Shmakova Anastasia. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var filteredImage: UIImage?
    
    var originalImage: UIImage?
    
    var imageProcessor: ImageProcessor?

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet var secondaryMenu: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageProcessor = ImageProcessor(image: imageView.image!)
        originalImage = imageView.image
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
    }

    @IBAction func onNewPhoto(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "New Photo", message: nil, preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action
            in
            self.showCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Album", style: .Default, handler: { action
            in
            self.showAlbum()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .Camera
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func showAlbum() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .PhotoLibrary
        
        presentViewController(cameraPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            originalImage = imageView.image
            imageProcessor = ImageProcessor(image: imageView.image!)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onFilter(sender: UIButton) {
        if (sender.selected) {
            hideSecondaryMenu()
            sender.selected = false
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
        
    }
    
    @IBAction func onGrayScale(sender: UIButton) {
        filteredImage = imageProcessor!.apply("Gray Scale")
        imageView.image = filteredImage
    }
    
    @IBAction func onSepia(sender: UIButton) {
        filteredImage = imageProcessor!.apply("Sepia")
        imageView.image = filteredImage
    }
    
    @IBAction func onNegative(sender: UIButton) {
        filteredImage = imageProcessor!.apply("Negative")
        imageView.image = filteredImage
    }

    
    @IBAction func onContrast(sender: UIButton) {
        filteredImage = imageProcessor!.apply("Contrast 100%")
        imageView.image = filteredImage
    }
    
    @IBAction func onBrightness(sender: UIButton) {
        filteredImage = imageProcessor!.apply("Brightness 2x")
        imageView.image = filteredImage
    }

    @IBAction func onCompare(sender: UIButton) {
        imageView.image = originalImage
    }
    
    @IBAction func onShare(sender: AnyObject) {
        let activityController = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        presentViewController(activityController, animated: true, completion: nil)
    }
    
    func showSecondaryMenu() {
        view.addSubview(secondaryMenu)
        
        let bottomConstraint = secondaryMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = secondaryMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = secondaryMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = secondaryMenu.heightAnchor.constraintEqualToConstant(44)
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()

        self.secondaryMenu.alpha = 0
        UIView.animateWithDuration(0.4) {
            self.secondaryMenu.alpha = 1.0
        }
    }
    
    func hideSecondaryMenu() {
        UIView.animateWithDuration(0.4, animations: {
            self.secondaryMenu.alpha = 0
            }) { completed in
            if completed == true {
                self.secondaryMenu.removeFromSuperview()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

