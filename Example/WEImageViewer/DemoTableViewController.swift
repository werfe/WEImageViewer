//
//  DemoTableViewController.swift
//  WEImageViewer
//
//  Created by vu.truong.giang on 5/5/18.
//

import UIKit
import WEImageViewer

class DemoTableViewController: UITableViewController {

    var objects = [String]()
    let imageViewer = WEImageViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false
        objects.append("image1.jpg")
        objects.append("image3.jpg")
        objects.append("image2.jpg")
        objects.append("image4.jpg")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        imageViewer.imagesDataSource = self
        imageViewer.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        // Configure the cell...
        if let imageView = cell.contentView.viewWithTag(101) as? UIImageView {
            imageView.image = UIImage(named: objects[indexPath.row])
            imageView.imageViewerController = imageViewer
            imageView.enableViewer(true)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width
    }
}

extension DemoTableViewController: WEImageViewerDataSource, WEImageViewerDelegate {
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

    func imageViewer(_ imageViewer: WEImageViewController, willShowAt index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if let visibleIndexes = tableView.indexPathsForVisibleRows, !visibleIndexes.contains(indexPath) {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        }

    }
}
