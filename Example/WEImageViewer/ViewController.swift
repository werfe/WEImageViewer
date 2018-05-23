//
//  ViewController.swift
//  WEImageViewer
//
//  Created by vu.truong.giang on 5/3/18.
//

import UIKit
import WEImageViewer

class ViewController: UIViewController {

    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var image5: UIImageView!

    var list = [UIImageView]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //list.append(image1)
        list.append(image2)
        list.append(image3)
        list.append(image4)
        //list.append(image5)

        let imageBrowser = WEImageViewController()
        
        imageBrowser.imagesDataSource = self

        image1.enableViewer(true, presentViewController: self.navigationController)
        image5.enableViewer(true, presentViewController: self.navigationController)
    }

}

extension ViewController: WEImageViewerDataSource {
    func numberOfImageInViewer() -> Int {
        return list.count
    }

    func imageViewAtIndex(_ imageViewer: WEImageViewController, index: Int) -> UIImageView? {
        return list[index]
    }

    func frameInWindowForItemAtIndex(_ imageViewer: WEImageViewController, index: Int) -> CGRect {
        return list[index].frame
    }
}
