//
//  UIViewController+PresentTransparent.swift
//  WEImageViewer
//
//  Created by vu.truong.giang on 5/3/18.
//

import UIKit

extension UIViewController {
    @objc func presentTransparent(_ viewController: UIViewController, completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .overFullScreen
        self.present(viewController, animated: false, completion: completion)
    }
}
