//
//  MainTableViewController.swift
//  WEImageViewer
//
//  Created by vu.truong.giang on 5/18/18.
//

import UIKit

class MainTableViewController: UITableViewController {

    var objects = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WEImageViewer Demo"
        objects.append("UITableViewController")
        objects.append("UICollectionViewController")
        objects.append("UIViewController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = objects[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            gotoTableViewControllerDemo()
        case 1:
            gotoCollectionViewControllerViewDemo()
        case 2:
            gotoViewControllerDemo()
        default:
            break
        }
    }

    func gotoTableViewControllerDemo() {
        let viewController = UIViewController.getViewControllerWithIdentifier("DemoTableViewController", storyboardName: "Main")
        navigationController?.pushViewController(viewController, animated: true)
    }

    func gotoCollectionViewControllerViewDemo() {
        let viewController = UIViewController.getViewControllerWithIdentifier("DemoCollectionViewController", storyboardName: "Main")
        navigationController?.pushViewController(viewController, animated: true)
    }

    func gotoViewControllerDemo() {
        let viewController = UIViewController.getViewControllerWithIdentifier("ViewController", storyboardName: "Main")
        navigationController?.pushViewController(viewController, animated: true)
    }

}

extension UIViewController {
    static func getViewControllerWithIdentifier(_ identifier: String, storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
}

