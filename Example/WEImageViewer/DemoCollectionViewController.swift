//
//  DemoCollectionViewController.swift
//  WEImageViewer
//
//  Created by vu.truong.giang on 5/5/18.
//

import UIKit
import WEImageViewer

private let reuseIdentifier = "DemoCollectionViewCell"

class DemoCollectionViewController: UICollectionViewController {
    var objects = [String]()
    let imageViewer = WEImageViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UINib.init(nibName: reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        for index in 1...50 {
            objects.append("\(index).png")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageViewer.imagesDataSource = self
        imageViewer.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 50
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! DemoCollectionViewCell
    
        // Configure the cell
        cell.coverImageView.image = UIImage(named: objects[indexPath.row])
        cell.coverImageView.imageViewerController = imageViewer
        cell.coverImageView.enableViewer(true)
        return cell
    }
    
}

extension DemoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/4 - 2, height: UIScreen.main.bounds.width/4 - 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
}

extension DemoCollectionViewController: WEImageViewerDataSource, WEImageViewerDelegate {
    func numberOfImageInViewer() -> Int {
        return objects.count
    }
    
    func imageViewAtIndex(_ imageViewer: WEImageViewController, index: Int) -> UIImageView? {
        if let cell = collectionView?.cellForItem(at: IndexPath(row: index, section: 0)) as? DemoCollectionViewCell {
            return cell.coverImageView
        }
        return nil
    }

    func frameInWindowForItemAtIndex(_ imageViewer: WEImageViewController, index: Int) -> CGRect {
        if let theAttributes = collectionView?.layoutAttributesForItem(at: IndexPath(row: index, section: 0)) {
            if let cellFrame = collectionView?.convert(theAttributes.frame, to: collectionView?.superview) {
                return cellFrame
            }
        }
        return .zero
    }

    func imageViewer(_ imageViewer: WEImageViewController, willShowAt index: Int) {
        guard let collectionView = collectionView else {
            return
        }
        if let theAttributes = collectionView.layoutAttributesForItem(at: IndexPath(row: index, section: 0)) {
            let cellFrame = collectionView.convert(theAttributes.frame, to: view)
            if collectionView.frame.contains(cellFrame) {
                return
            } else if collectionView.frame.intersects(cellFrame) {
                if cellFrame.origin.y < collectionView.frame.origin.y {
                    collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .top, animated: false)
                } else if cellFrame.origin.y + cellFrame.height >= collectionView.frame.height + collectionView.frame.origin.y {
                    collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
                }
                return
            }
        }
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
    }
}
