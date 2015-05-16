//
//  ViewController.swift
//  AAImagePickerControllerDemo
//
//  Created by Anas perso on 16/05/15.
//  Copyright (c) 2015 Anas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
}

