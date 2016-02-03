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
    
    var currentFilter: Filter?
    
    var currentIntensity: Double = 100

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topImageView: UIImageView!

    @IBOutlet weak var bottomMenu: UIView!
    
    @IBOutlet var secondaryMenu: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var compareButton: UIButton!
    
    @IBOutlet weak var overlayLabel: UILabel!
    
    @IBOutlet weak var intensitySlider: UISlider!
    
    @IBOutlet var sliderMenu: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        compareButton.enabled = false
        editButton.enabled = false
        
        imageProcessor = ImageProcessor(image: imageView.image!)
        originalImage = imageView.image
        secondaryMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        secondaryMenu.translatesAutoresizingMaskIntoConstraints = false
        sliderMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        sliderMenu.translatesAutoresizingMaskIntoConstraints = false
        
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
        hideSliderMenu()
        editButton.enabled = false
        compareButton.enabled = false
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
        } else {
            showSecondaryMenu()
            sender.selected = true
        }
        
    }
    
    func filterApply() {
        editButton.enabled = true
        compareButton.enabled = true
        compareButton.selected = false
        filteredImage = imageProcessor!.apply(currentFilter!)
        showFilteredImage()
    }
    
    @IBAction func onGrayScale(sender: UIButton) {
        currentIntensity = 100
        currentFilter = GrayScaleFilter(intensity: currentIntensity)
        filterApply()
    }
    
    @IBAction func onSepia(sender: UIButton) {
        currentIntensity = 100
        currentFilter = SepiaFilter(intensity: currentIntensity)
        filterApply()
        
    }
    
    @IBAction func onNegative(sender: UIButton) {
        currentIntensity = 100
        currentFilter = NegativeFilter(intensity: currentIntensity)
        filterApply()
    }

    
    @IBAction func onContrast(sender: UIButton) {
        currentIntensity = 200
        currentFilter = ContrastFilter(intensity: currentIntensity)
        filterApply()
    }
    
    @IBAction func onBrightness(sender: UIButton) {
        currentIntensity = 100
        currentFilter = BrightnessFilter(intensity: currentIntensity)
        filterApply()
    }
    
    @IBAction func onEdit(sender: UIButton) {
        if (sender.selected) {
            hideSliderMenu()
        } else {
            showSliderMenu()
        }
    }
    
    
    @IBAction func onSlider(sender: UISlider) {
        currentIntensity = Double(sender.value)
        currentFilter?.intensity = currentIntensity
        filterApply()
    }
    
    func showSliderMenu() {
        editButton.selected = true
        intensitySlider.value = Float(currentIntensity)
        hideSecondaryMenu()
        
        view.addSubview(sliderMenu)
        
        let bottomConstraint = sliderMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstraint = sliderMenu.leftAnchor.constraintEqualToAnchor(view.leftAnchor)
        let rightConstraint = sliderMenu.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        let heightConstraint = sliderMenu.heightAnchor.constraintEqualToConstant(44)
            
        NSLayoutConstraint.activateConstraints([bottomConstraint, leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.sliderMenu.alpha = 0
        
        UIView.animateWithDuration(0.4) {
            self.sliderMenu.alpha = 1.0
        }
    }
    
    func hideSliderMenu() {
        editButton.selected = false
        
        UIView.animateWithDuration(0.4, animations: {
            self.sliderMenu.alpha = 0
            }) { completed in
                if completed == true {
                    self.sliderMenu.removeFromSuperview()
                }
        }
        
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
        filterButton.selected = true
        hideSliderMenu()
        
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
        filterButton.selected = false
        
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

