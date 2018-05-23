# WEImageViewer

[![CI Status](https://img.shields.io/travis/werfe/WEImageViewer.svg?style=flat)](https://travis-ci.org/werfe/WEImageViewer)
[![Version](https://img.shields.io/cocoapods/v/WEImageViewer.svg?style=flat)](https://cocoapods.org/pods/WEImageViewer)
[![License](https://img.shields.io/cocoapods/l/WEImageViewer.svg?style=flat)](https://cocoapods.org/pods/WEImageViewer)
[![Platform](https://img.shields.io/cocoapods/p/WEImageViewer.svg?style=flat)](https://cocoapods.org/pods/WEImageViewer)

<img src="https://github.com/werfe/WEImageViewer/blob/master/Example/WEImageViewer/images/animation.gif?raw=true" width="320">

Description
--------------


# Table of Contents
1. [Example](#example)
3. [Installation](#installation)
4. [Supported versions](#supported-versions)
5. [Usage](#usage)
6. [Attributes](#attributes)
8. [Public interface](#public-interface)
9. [License](#license)
10. [Contact](#contact)


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation
* via CocoaPods
WEImageViewer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WEImageViewer'
```

<a name="supported-versions"> Supported Versions </a>
-----------------------------

* iOS 10.0 or later

<a name="usage"> Usage </a>
--------------

### UIImageView

```swift
imageView.enableViewer(true, presentViewController: self.navigationController)
// Or
imageView.enableViewer(true) // Viewer will be presented by UIApplication.share.keyWindows.rootViewController
// Or
let imageBrowser = WEImageViewController()
imageBrowser.show(self.navigationController, senderView: imageView)

```

### UITableViewController, UICollectionViewController

**Step 1.** Declare the viewer as property

```swift
let imageViewer = WEImageViewController()
```
**Step 2.** In table view delegate function `func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)`, setup image viewer controller for the cell's image view
```swift
override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DemoCollectionViewCell
    // Configure the cell
    cell.coverImageView.imageViewerController = imageViewer
    cell.coverImageView.enableViewer(true)
    return cell
}
```

**Step 3.** Adopt WEImageViewerDataSource, WEImageViewerDelegate
```swift
func numberOfImageInViewer() -> Int {
    return objects.count
}

func imageViewAtIndex(_ imageViewer: WEImageViewController, index: Int) -> UIImageView? {
    let indexPath = IndexPath(row: index, section: 0)
    if let cell = tableView.cellForRow(at: indexPath) {
        return cell.contentView.viewWithTag(101) as? UIImageView
    }
    return nil
}

func frameInWindowForItemAtIndex(_ imageViewer: WEImageViewController, index: Int) -> CGRect {
    let indexPath = IndexPath(row: index, section: 0)
    let rect = tableView.rectForRow(at: indexPath)
    return tableView.convert(rect, to: nil)
}

// Scroll to the cell has an image will be showing on viewer to make sure the dismissal animation will work correctly when user close viewer
func imageViewer(_ imageViewer: WEImageViewController, willShowAt index: Int) {
    //This is my sample code, you can do some more to make it better
    let indexPath = IndexPath(row: index, section: 0)
    if let visibleIndexes = tableView.indexPathsForVisibleRows, !visibleIndexes.contains(indexPath) {
        tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
}

```

<a name="attributes"> Attributes </a>
--------------

| Attribute for drawing  |  Value |      Description      |
|----------|-----|-----------------------------|
|`imagesDataSource`| WEImageViewerDataSource | The data source provides the image viewer controller object with the information it needs to construct and modify a viewer.|
|`delegate`| WEImageViewerDelegate | The delegate must adopt the WEImageViewerDelegate protocol. Optional methods of the protocol allow the delegate to manage some actions in viewer controller.|
|`rootViewController`| UIViewController | The controller will present the image viewer controller. The viewer would be presneted by `keyWindow` if  `rootViewController` is `nil` |
|`selectedIndex`| Int |  Index of current showing image in the viewer|


<a name="public-interface"> Public interface </a>
--------------

### WEImageViewerDataSource

```swift
func numberOfImageInViewer() -> Int
func imageViewAtIndex(_ imageViewer: WEImageViewController, index: Int) -> UIImageView?
func frameInWindowForItemAtIndex(_ imageViewer: WEImageViewController, index: Int) -> CGRect
optional func imageURLAtIndex(_ imageViewer: WEImageViewController, index: Int) -> URL?

```

### WEImageViewerDelegate

```swift
optional func imageViewer(_ imageViewer: WEImageViewController , willShowAt index: Int)

```


## <a name="contact"> Contact </a>

You can contact me at email adress werfeee@gmail.com. If you found any issues on the project, please open a ticket. Pull requests are also welcome.


## License

```WEImageViewer``` is developed by GiangVT (aka Werfe) and is released under the MIT license. See the ```LICENSE``` file for more details.

In my Sample project, background image is downloaded from [ilikewallpaper](http://www.ilikewallpaper.net/) and [Pinterest](www.pinterest.com). Thanks.
