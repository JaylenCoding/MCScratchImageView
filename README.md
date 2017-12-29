# MCScratchImageView

![MCScratchImageView](http://p0h33xrro.bkt.clouddn.com/MCScratchImageView_MCScratchViewHeader.png)

[![platform](https://img.shields.io/badge/platform-iOS-blue.svg)](https://developer.apple.com/) [![Swift](https://img.shields.io/badge/Swift-4.0-orange.svg)](https://developer.apple.com/swift/) [![license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/Minecodecraft/MCScratchImageView/blob/master/LICENSE)

---
### GIF Showcase
![Showcase1](https://github.com/Minecodecraft/MCScratchImageView/blob/master/GIFShowcase/Showcase1.gif)

![Showcase2](https://github.com/Minecodecraft/MCScratchImageView/blob/master/GIFShowcase/Showcase2.gif)

---

## Requirments
iOS 8.0+
Xcode 7.2+
Swift 4.0

## Installation

#### CocoaPods

```ruby
pod "MCScratchImageView"
```

#### Manually

Just drag `MCScratchImageView.swift` to the project tree

## Usage

#### Import

If you use CocoaPods, first import MCScratchImageView
```Swift
import MCScratchImageView
```

#### Define the class variables

```Swift
var scratchImageView: MCScratchImageView!
```

#### Initialize it

```Swift
// init()
scratchImageView = MCScratchImageView()
// init(frame:)
scratchImageView = MCScratchImageView(frame: yourRect)
```
Or use StoryBoard.

#### Set the mask image & radius

```Swift
// use default touch point radius
scratchImageView.setMaskImage(yourUIImage)
// use custom touch point radius
scratchImageView.setMaskImage(yourUIImage, spotRadius: 100)
```

#### Implement the delegate methods:

```Swift
// set the delegate
scratchImageView.delegate = ***

/* ... */

// implement the MCScratchImageViewDelegate method
extension YourController: MCScratchImageViewDelegate {
    
    func mcScratchImageView(_ mcScratchImageView: MCScratchImageView, didChangeProgress progress: CGFloat) {
        print("Progress did changed: " + String(format: "%.2f", progress))
        if (progress >= 0.8) {
            mcScratchImageView.scratchAll()
        }
    }
    
}
```

#### API declaration

```Swift
// current scratched progress
public var progress: CGFloat
// Determin the radius of the touch point
private(set) var spotRadius: CGFloat = 45.0

// set the mask image & radius
public func setMaskImage(_ image: UIImage)
public func setMaskImage(_ image: UIImage, spotRadius: CGFloat)

// scratch all mask fields
public func scratchAll()
```

#### Example Project
In "Example" folder.

#### Tips

- Don't set the scratchImageView.image directlly, you need to use setMaskImage(paras) to set the mask image.
- Don't set the touch point radius (var spotRadius: CGFloat) directlly.
- The contentMode should use default resize mode.

## Author

Minecode, [minecoder@163.com](mailto:minecoder@163.com)

## License

MCScratchImageView is available under the MIT license. See the LICENSE file for more info.