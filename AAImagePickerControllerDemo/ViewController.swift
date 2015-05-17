//
//  ViewController.swift
//  AAImagePickerControllerDemo
//
//  Created by Anas perso on 16/05/15.
//  Copyright (c) 2015 Anas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  @IBOutlet weak var scrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func showPicker(sender: AnyObject) {
    let pc = AAImagePickerController()
    pc.pickerDelegate = self
    self.presentViewController(pc, animated: true, completion: nil)
  }
}

extension ViewController : AAImagePickerControllerDelegate {
  func imagePickerControllerDidCancel() {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidFinishSelection(images: [ImageItem]) {
    self.dismissViewControllerAnimated(true, completion: nil)
    println("\(images.count) selected items")
    scrollView.subviews.map({ $0.removeFromSuperview() })
    for (index, item) in enumerate(images) {
      let imageHeight: CGFloat = scrollView.bounds.height / 2
      let imageView = UIImageView(image: item.image)
      imageView.contentMode = UIViewContentMode.ScaleAspectFit
      imageView.frame = CGRect(x: 0, y: CGFloat(index) * imageHeight, width: scrollView.bounds.width, height: imageHeight)
      scrollView.addSubview(imageView)
      
    }
    scrollView.contentSize.height = CGRectGetMaxY((scrollView.subviews.last as! UIView).frame)
  }
}

