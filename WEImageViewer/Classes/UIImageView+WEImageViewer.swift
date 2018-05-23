//
//  UIImageView+WEImageViewer.swift
//  WEImageViewer
//
//  Created by vu.truong.giang on 5/3/18.
//

import UIKit

extension UIImageView {
    private struct AssociatedKeys {
        static var kImageViewerControllerKey = "kImageViewerControllerKey"
    }

    @objc open weak var imageViewerController: WEImageViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kImageViewerControllerKey) as? WEImageViewController
        }

        set {
            if let newValue = newValue {
                weak var weakValue = newValue
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.kImageViewerControllerKey,
                    weakValue,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            } else {
                if let imageViewerController = imageViewerController {
                    objc_removeAssociatedObjects(imageViewerController)
                }
            }
        }
    }
    @objc open func enableViewer(_ enabled: Bool, presentViewController: UIViewController? = nil) {
        if let gestures = gestureRecognizers {
            for gesture in gestures {
                if let gesture = gesture as? UITapGestureRecognizer {
                    removeGestureRecognizer(gesture)
                }
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true

        var presentVC = presentViewController
        if presentVC == nil {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                presentVC = rootViewController
            }
        }

        if let imageViewerController = imageViewerController {
            imageViewerController.rootViewController = presentVC
        } else {
            imageViewerController = WEImageViewController()
            imageViewerController?.rootViewController = presentVC
        }
    }

    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        if let imageViewerController = imageViewerController {
            imageViewerController.show(senderView: self)
        } else {
            let viewer = WEImageViewController()
            viewer.show(senderView: self)
        }
    }
}
