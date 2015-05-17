# AAImagePickerController
Custom ImagePickerController with camera option, multiselect and quick album selection

*Screenshots comming soon*


## Features

- Allows multiple selection of photos
- Allows to take a picture
- Allow easy selection of an album
- Customizable (number of columns, maximumSelection, etc.)
- Supports both portrait mode and landscape mode
- Fast and memory-efficient scrolling
- Compatible with all iPhone and iPad (Tested from iOS 7.0)

## Example

    let pc = AAImagePickerController()
    pc.pickerDelegate = self
    pc.allowsMultipleSelection = true // Default value is true
    pc.maximumNumberOfSelection = 6 // Default value is 0 (unlimited)
    pc.numberOfColumnInPortrait = 5 // Default value is 4
    pc.numberOfColumnInLandscape = 10 // Default value is 7
    
    self.presentViewController(pc, animated: true, completion: nil)


## Installation

### CocoaPods

*Comming soon*

### Carthage

*Comming soon*

### Manual

1. Add `AAImagePickerController.swift`, `check.png`, `take_photo.png` and `AKPickerView.swift` to your project
2. That's all you can use it!

## Usage

### Basic

1. Implement `AAImagePickerControllerDelegate` methods
2. Initialize a new `AAImagePickerController` object
3. Set `self` to the `delegate` property
4. Show the picker by using `presentViewController:animated:completion:`
```
    let pc = AAImagePickerController()
    pc.pickerDelegate = self
    
    self.presentViewController(pc, animated: true, completion: nil)
```

### Delegate Methods

#### Getting the selected items

Implement `imagePickerControllerDidFinishSelection` to get the items selected by the user.  
This method will be called when the user finishes selecting images.

    func imagePickerControllerDidFinishSelection(images: [ImageItem]) {
      for (index, item) in enumerate(images) {
        let imageView = UIImageView(image: item.image)
        ...
      }
      self.dismissViewControllerAnimated(true, completion: nil)
    }


#### Getting notified when the user cancels

Implement `imagePickerControllerDidCancel` to get notified when the user hits "Cancel" button.

    func imagePickerControllerDidCancel() {
      self.dismissViewControllerAnimated(true, completion: nil)
    }

### Customization

#### Selection mode

When `allowsMultipleSelection` is `true`, the user can select multiple photos.  
The default value is `true`.

    pc.allowsMultipleSelection = true

You can limit the number of selection `maximumNumberOfSelection` property.  
The default value is `0`, which means the number of selection is unlimited.

    pc.maximumNumberOfSelection = 6

#### Number of columns

Use `numberOfColumnInPortrait` and `numberOfColumnInLandscape` to change the number of columns in the specified orientation.  
The code below shows the default value.

    pc.numberOfColumnInPortrait = 4
    pc.numberOfColumnInLandscape = 7


## License

The MIT License (MIT)

Copyright (c) 2015 Anas AIT-ALI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
