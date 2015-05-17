//
//  AAImagePickerController.swift
//  AAImagePickerControllerDemo
//
//  Created by Anas perso on 16/05/15.
//  Copyright (c) 2015 Anas. All rights reserved.
//

import UIKit
import AssetsLibrary

// MARK: - Constants
let AAImageCellIdentifier = "AAImageCellIdentifier"
let AATakePhotoCellIdentifier = "AATakePhotoCellIdentifier"

// MARK: - AAImagePickerControllerDelegate
protocol AAImagePickerControllerDelegate : NSObjectProtocol {
  func imagePickerControllerDidCancel()
}

// MARK: - Models
class ImageGroup {
  var name: String!
  var group: ALAssetsGroup!
}

class ImageItem : NSObject {
  private var originalAsset: ALAsset!
  var thumbnailImage: UIImage?
  lazy var fullScreenImage: UIImage? = {
    return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
    }()
  lazy var fullResolutionImage: UIImage? = {
    return UIImage(CGImage: self.originalAsset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
    }()
  var url: NSURL?
}

// MARK: - AAImagePickerController
class AAImagePickerController : UINavigationController {

  internal weak var pickerDelegate : AAImagePickerControllerDelegate?
  var listController : AAImagePickerControllerList!
  var selectionColor = UIColor.clearColor() {
    didSet {
      self.listController.selectionColor = selectionColor
    }
  }
  
  // MARK: Initialization
  convenience init() {
    let aListController = AAImagePickerControllerList()
    self.init(rootViewController: aListController)
    listController = aListController
  }
  
  // MARK: View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: UINavigationController
  override func pushViewController(viewController: UIViewController, animated: Bool) {
    super.pushViewController(viewController, animated: animated)
    
    self.topViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Done, target: self, action: "cancelAction")

    if self.viewControllers.count == 1 &&
      self.topViewController?.navigationItem.leftBarButtonItem == nil {
      self.topViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelAction")
    }
  }
  
  // MARK: Delegate
  func cancelAction() {
    if let aDelegate = self.pickerDelegate {
      aDelegate.imagePickerControllerDidCancel()
    }
  }
 
}

// MARK: - AAImagePickerControllerList
class AAImagePickerControllerList : UICollectionViewController {

  lazy private var albumPickerView = AKPickerView()
  lazy private var library: ALAssetsLibrary = {
    return ALAssetsLibrary()
    }()
  lazy private var groups: NSMutableArray = {
    return NSMutableArray()
    }()
  private lazy var imageItems: NSMutableArray = {
    return NSMutableArray()
    }()
  internal var selectedItems = [ImageItem]()
  var selectionColor = UIColor.cyanColor().colorWithAlphaComponent(0.5)
  
  // MARK: Initialization
  override init(collectionViewLayout layout: UICollectionViewLayout) {
    super.init(collectionViewLayout: layout)
  }
  
  convenience init() {
    let layout = UICollectionViewFlowLayout()
    
    let interval: CGFloat = 3
    layout.minimumInteritemSpacing = interval
    layout.minimumLineSpacing = interval
    
    let screenWidth = UIScreen.mainScreen().bounds.width
    let itemWidth = (screenWidth - interval * 3) / 4
    
    layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
    
    self.init(collectionViewLayout: layout)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: View lifecycle
  override func viewDidLoad() {
    
    albumPickerInitialisation()
    updateGroups { () -> () in
      self.updateImagesList()
    }
    
    self.collectionView!.backgroundColor = UIColor.whiteColor()
    self.collectionView!.allowsMultipleSelection = true
    self.collectionView!.registerClass(AAImagePickerCollectionCell.self, forCellWithReuseIdentifier: AAImageCellIdentifier)
    self.collectionView!.registerClass(AATakePhotoCollectionCell.self, forCellWithReuseIdentifier: AATakePhotoCellIdentifier)
  }
  
  // MARK: Library methods
  func updateGroups(callback: () -> ()) {
    library.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      if group != nil {
        if group.numberOfAssets() != 0 {
          let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String
          let assetGroup = ImageGroup()
          assetGroup.name = groupName
          assetGroup.group = group
          self.groups.insertObject(assetGroup, atIndex: 0)
        }
      } else {
        self.albumPickerView.reloadData()
        callback()
      }
      }, failureBlock: { (error: NSError!) -> Void in
        // TODO : Handle this case by showing a message
        assertionFailure("access denied")
    })
  }
  
  func updateImagesList() {
    let selectedAlbum = self.albumPickerView.selectedItem
    let currentGroup = groups[selectedAlbum] as! ImageGroup

    self.imageItems.removeAllObjects()
    currentGroup.group.enumerateAssetsUsingBlock { (result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      if result != nil {
        let item = ImageItem()
        item.thumbnailImage = UIImage(CGImage:result.thumbnail().takeUnretainedValue())
        item.url = result.valueForProperty(ALAssetPropertyAssetURL) as? NSURL
        item.originalAsset = result
        self.imageItems.insertObject(item, atIndex: 0)
      } else {
        self.collectionView!.reloadData()
      }
    }
  }
  
  // MARK: UICollectionViewDataSource
  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return imageItems.count + 1
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    if indexPath.row == 0 {
      let takePhotoCell = collectionView.dequeueReusableCellWithReuseIdentifier(AATakePhotoCellIdentifier, forIndexPath: indexPath) as! AATakePhotoCollectionCell
      return takePhotoCell
    } else {
      let item = imageItems[indexPath.row - 1] as! ImageItem
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AAImageCellIdentifier, forIndexPath: indexPath) as! AAImagePickerCollectionCell
      cell.thumbnail = item.thumbnailImage
      cell.selectionColor = selectionColor
      if find(selectedItems, item) != nil {
        cell.selected = true
      } else {
        cell.selected = false
      }
      return cell
    }
  }
  
  // MARK: UICollectionViewDelegate
  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row == 0 {
      collectionView.deselectItemAtIndexPath(indexPath, animated: false)
      if UIImagePickerController.isSourceTypeAvailable(.Camera) {
        var picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(picker, animated: true, completion: nil)
      } else {
        let alert = UIAlertView(title: "Error", message: "This device has no camera", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
      }
    } else {
      let item = imageItems[indexPath.row - 1] as! ImageItem
      selectedItems.append(item)
    }
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    if indexPath.row != 0 {
      let item = imageItems[indexPath.row - 1] as! ImageItem
      selectedItems.removeAtIndex(find(selectedItems, item)!)
    }
  }
  
}

extension AAImagePickerControllerList : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    // TODO : Handle taken pictures
    println(info)
    picker.dismissViewControllerAnimated(true, completion:nil)
    self.dismissViewControllerAnimated(false, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
}

extension AAImagePickerControllerList : AKPickerViewDelegate, AKPickerViewDataSource {
  
  func albumPickerInitialisation() {
    self.albumPickerView.delegate = self
    self.albumPickerView.dataSource = self
    self.albumPickerView.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
    self.albumPickerView.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
    self.albumPickerView.interitemSpacing = 10.0
    self.albumPickerView.viewDepth = 1000.0
    self.albumPickerView.pickerViewStyle = .Wheel
    self.albumPickerView.maskDisabled = false
    self.albumPickerView.autoresizingMask =  UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
    if self.navigationController != nil {
      self.albumPickerView.frame = self.navigationController!.navigationBar.bounds
    }
    self.navigationItem.titleView = self.albumPickerView
  }
  
  func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
    return groups.count
  }
  
  func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
    let assetGroup : ImageGroup = groups[item] as! ImageGroup
    return assetGroup.name
  }
  
  func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
    let assetGroup : ImageGroup = groups[item] as! ImageGroup
    updateImagesList()
  }
}

// MARK: - UIImage extension
extension UIImage {
  func imageWithColor(color: UIColor) -> UIImage {
    let rect = CGRectMake(0, 0, self.size.width, self.size.height)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    color.set()
    CGContextTranslateCTM(context, 0, self.size.height)
    CGContextScaleCTM(context, 1.0, -1.0)
    CGContextClipToMask(context, rect, self.CGImage)
    CGContextFillRect(context, rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}

// MARK: - AAImagePickerCollectionCell
class AAImagePickerCollectionCell: UICollectionViewCell {
  private var imageView = UIImageView()
  private var selectedView = UIImageView(image: UIImage(named: "check"))

  var selectionColor = UIColor.clearColor() {
    didSet {
      layer.borderColor = selectionColor.CGColor
      selectedView.image = selectedView.image?.imageWithColor(selectionColor)
    }
  }
  
  var thumbnail: UIImage! {
    didSet {
      self.imageView.image = thumbnail
    }
  }
  
  override var selected: Bool {
    didSet {
      selectedView.hidden = !super.selected
      layer.borderWidth = super.selected ? 1 : 0
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    imageView.frame = self.bounds
    self.contentView.addSubview(imageView)
    self.contentView.addSubview(selectedView)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    imageView.frame = self.bounds
    selectedView.frame.size = CGSizeMake(self.contentView.bounds.width / 5, self.contentView.bounds.height / 5)
    selectedView.frame.origin = CGPoint(x: self.contentView.bounds.width - selectedView.bounds.width - 3,
      y: self.contentView.bounds.height - selectedView.bounds.height - 3)
  }
}

// MARK: - AATakePhotoCollectionCell
class AATakePhotoCollectionCell: UICollectionViewCell {
  private var imageView = UIImageView(image: UIImage(named: "take_photo"))
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    imageView.frame = self.bounds
    self.contentView.addSubview(imageView)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    imageView.frame = self.bounds
  }
}

