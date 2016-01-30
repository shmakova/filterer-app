//
//  ViewController.swift
//  Filterer
//
//  Created by Anastasia Shmakova on 18.01.16.
//  Copyright © 2016 Shmakova Anastasia. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var filteredImage: UIImage?
    
    var originalImage: UIImage?
    
    var imageProcessor: ImageProcessor?

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topImageView: UIImageView!

    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet var secondaryMenu: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var compareButton: UIButton!
    
    @IBOutlet weak var overlayLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        compareButton.enabled = false
        
        imageProcessor = ImageProcessor(image: imageView.image!)
        originalImage = imageView.image
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("longPress:"))
        longPressGestureRecognizer.minimumPressDuration = 0.05
        imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func longPress(gesture: UITapGestureRecognizer) {
        if (filteredImage != nil) {
            compareButton.selected = false
            
            if gesture.state == .Began {
                showOriginalImage()
            } else if gesture.state == .Ended {
                showFilteredImage()
            }
        }
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
    
    func showOriginalImage() {
        topImageView.alpha = 0
        topImageView.image = originalImage
        
        UIView.animateWithDuration(0.4, animations: {
            self.topImageView.alpha = 1
            }) { completed in
                if completed == true {
                    self.imageView.image = self.originalImage
                    self.topImageView.alpha = 0
                    self.imageView.addSubview(self.overlayLabel)
                    self.overlayLabel.hidden = false
                }
        }
    }
    
    func showFilteredImage() {
        topImageView.alpha = 0
        topImageView.image = filteredImage
        
        UIView.animateWithDuration(0.4, animations: {
            self.topImageView.alpha = 1
            }) { completed in
                if completed == true {
                    self.imageView.image = self.filteredImage
                    self.topImageView.alpha = 0
                    self.overlayLabel.hidden = true
                }
        }
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
    
    func filterApply(filterName: String) {
        compareButton.enabled = true
        compareButton.selected = false
        filteredImage = imageProcessor!.apply(filterName)
        showFilteredImage()
    }
    
    @IBAction func onGrayScale(sender: UIButton) {
        filterApply("Gray Scale")
    }
    
    @IBAction func onSepia(sender: UIButton) {
        filterApply("Sepia")
    }
    
    @IBAction func onNegative(sender: UIButton) {
        filterApply("Negative")
    }

    
    @IBAction func onContrast(sender: UIButton) {
        filterApply("Contrast 100%")
    }
    
    @IBAction func onBrightness(sender: UIButton) {
        filterApply("Brightness 2x")
    }

    @IBAction func onCompare(sender: UIButton) {
        if (sender.selected) {
            showFilteredImage()
            sender.selected = false
        } else {
            showOriginalImage()
            sender.selected = true
        }
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
        
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint])
        
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

