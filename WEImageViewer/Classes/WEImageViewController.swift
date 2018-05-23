//
//  WEImageViewController.swift
//  WEImageViewer
//
//  Created by vu.truong.giang on 5/3/18.
//

import UIKit
import FLAnimatedImage
import PINRemoteImage
import PINCache

private struct Constant {
    static let maximumOpacity: CGFloat = 1.0
    static let minimumScale: CGFloat = 1.0
    static let maximumScale: CGFloat = 4.0
    static let animationDuration: TimeInterval = 0.35
    static let scaleParentView: CGFloat = 1 //0.95
    static let itemSpacing: CGFloat = 20
}

@objc public protocol WEImageViewerDataSource {
    @objc func numberOfImageInViewer() -> Int
    @objc func imageViewAtIndex(_ imageViewer: WEImageViewController, index: Int) -> UIImageView?
    @objc func frameInWindowForItemAtIndex(_ imageViewer: WEImageViewController, index: Int) -> CGRect
    @objc optional func imageURLAtIndex(_ imageViewer: WEImageViewController, index: Int) -> URL?
}

@objc public protocol WEImageViewerDelegate {
    @objc optional func imageViewer(_ imageViewer: WEImageViewController , willShowAt index: Int)
}

private protocol ImageViewCollectionCellDelegate: class {
    func willCloseAt(_ cell: ImageViewCollectionCell)
    func beginCloseAt(_ cell: ImageViewCollectionCell)
    func didCloseAt(_ cell: ImageViewCollectionCell)
    func didCancelCloseAt(_ cell: ImageViewCollectionCell)
    func adjustBacgroundOpacity(_ opacity: CGFloat)
}

private let reuseIdentifier = "WECollectionViewCell"

open class WEImageViewController: UIViewController {

    open weak var imagesDataSource: WEImageViewerDataSource? {
        didSet {
            for index in 0..<(imagesDataSource?.numberOfImageInViewer() ?? 0) {
                if let sender = imagesDataSource?.imageViewAtIndex(self, index: index) {
                    sender.enableViewer(true, presentViewController: rootViewController)
                    sender.imageViewerController = self
                } else {

                }
            }
        }
    }
    open weak var sender: UIImageView?
    open weak var delegate: WEImageViewerDelegate?
    open weak var rootViewController: UIViewController?
    open var selectedIndex: Int = 0
    fileprivate var collectionView: UICollectionView!

    //MARK: - Public methods
    public convenience init() {
        self.init(nil)
    }

    public init(_ sender: UIImageView?) {
        self.sender = sender
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initViews()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createAnimatedImage()
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @objc open func show(_ viewController: UIViewController? = nil, senderView: UIImageView? = nil) {
        selectedIndex = indexOf(senderView)
        self.sender = senderView
        if let viewController = viewController {
            rootViewController = viewController
        } else if rootViewController == nil {
            if let rootViewController = UIApplication.shared.keyWindow?.rootViewController  {
                self.rootViewController = rootViewController
            }
        }
        rootViewController?.presentTransparent(self)
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.invalidateLayout()
        }
    }

    //MARK: - Private methods

    func indexOf(_ imageView: UIImageView?) -> Int {
        if let dataSource = self.imagesDataSource {
            for index in 0..<dataSource.numberOfImageInViewer() {
                if imageView == dataSource.imageViewAtIndex(self, index: index) {
                    return index
                }
            }
        }
        return 0
    }

    fileprivate func initViews() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = UIScreen.main.bounds.size
        flowLayout.minimumLineSpacing = Constant.itemSpacing
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImageViewCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        if #available(iOS 9.0, *) {
            collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }

        collectionView.isHidden = true
    }

    private func calculateOriginRect(_ image: UIImage?) -> CGRect {
        guard let image = image else {
            return .zero
        }
        let imageRatio = image.size.width / image.size.height
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        if view.frame.width / view.frame.height <= imageRatio {
            newWidth = view.frame.width
            newHeight = newWidth / imageRatio
        } else {
            newHeight = view.frame.height
            newWidth = newHeight * imageRatio
        }

        let x: CGFloat = (view.frame.width - newWidth) / 2
        let y: CGFloat = (view.frame.height - newHeight) / 2

        return CGRect(x: x, y: y, width: newWidth, height: newHeight)
    }

    private func createAnimatedImage() {
        //animating image view
        let animatedImageView = UIImageView()
        animatedImageView.clipsToBounds = true
        if let dataSource = imagesDataSource {
            if let imageView = dataSource.imageViewAtIndex(self, index: selectedIndex) {
                animatedImageView.image = imageView.image
                animatedImageView.contentMode = imageView.contentMode
                self.view.addSubview(animatedImageView)
                animatedImageView.frame = dataSource.frameInWindowForItemAtIndex(self, index: selectedIndex)
                imageView.isHidden = true
                self.sender = imageView
            }
        } else {
            if let imageView = sender {
                animatedImageView.image = imageView.image
                animatedImageView.contentMode = imageView.contentMode
                self.view.addSubview(animatedImageView)
                if let sender = sender {
                    animatedImageView.frame = sender.superview?.convert(sender.frame, to: nil) ?? .zero
                } else {
                     animatedImageView.frame = .zero
                }
                imageView.isHidden = true
            }
        }

        let originRect = calculateOriginRect(animatedImageView.image)
        collectionView.isHidden = true
        self.adjustBacgroundOpacity(0)
        let indexPath = IndexPath(item: selectedIndex, section: 0)
        let hidingSender = imagesDataSource?.imageViewAtIndex(self, index: indexPath.row)
        if animatedImageView.frame == .zero {
            animatedImageView.alpha = 0.0
            UIView.animate(withDuration: Constant.animationDuration, animations: {
                animatedImageView.alpha = 1.0
                self.adjustBacgroundOpacity(Constant.maximumOpacity)
                self.rootViewController?.view.transform = CGAffineTransform.init(scaleX: Constant.scaleParentView, y: Constant.scaleParentView)
            }, completion: { (finished) in
                if finished {
                    self.updateCollectionView()
                    self.collectionView.isHidden = false
                    animatedImageView.removeFromSuperview()
                    hidingSender?.isHidden = false
                    //Reason https://stackoverflow.com/a/10712278
                    self.rootViewController?.view.transform = CGAffineTransform.identity
                }
            })
        } else {
            UIView.animate(withDuration: Constant.animationDuration, animations: {
                animatedImageView.frame = originRect
                self.adjustBacgroundOpacity(Constant.maximumOpacity)
                self.rootViewController?.view.transform = CGAffineTransform.init(scaleX: Constant.scaleParentView, y: Constant.scaleParentView)
            }, completion: { (finished) in
                if finished {
                    self.updateCollectionView()
                    self.collectionView.isHidden = false
                    animatedImageView.removeFromSuperview()
                    hidingSender?.isHidden = false
                    //Reason https://stackoverflow.com/a/10712278
                    self.rootViewController?.view.transform = CGAffineTransform.identity
                }
            })
        }
    }

    private func updateCollectionView() {
        collectionView.reloadData()
        if imagesDataSource != nil {
            collectionView.scrollToItem(at: IndexPath(row: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
}

//MARK: - Collection View Datasource, Delegate
extension WEImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesDataSource?.numberOfImageInViewer() ?? 1
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: ImageViewCollectionCell
        if let c = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageViewCollectionCell {
            cell = c
        } else {
            cell = ImageViewCollectionCell()
        }
        delegate?.imageViewer?(self, willShowAt: indexPath.row)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageViewCollectionCell {
            cell.updateImageViewRect()
        }
        return UIScreen.main.bounds.size
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let sender = imagesDataSource?.imageViewAtIndex(self, index: indexPath.row) ?? self.sender
        if let cell = cell as? ImageViewCollectionCell {
            cell.image = sender?.image
            if let dataSource = imagesDataSource {
                cell.fromRect = dataSource.frameInWindowForItemAtIndex(self, index: indexPath.row)
                cell.url = dataSource.imageURLAtIndex?(self, index: indexPath.row)
            } else {
                if let sender = sender {
                    cell.fromRect = sender.superview?.convert(sender.frame, to: nil) ?? .zero
                } else {
                    cell.fromRect = .zero
                }
            }
            cell.senderContentMode = sender?.contentMode
            cell.delegate = self
            cell.configureCell()
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let dataSource = imagesDataSource,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: IndexPath(row: selectedIndex, section: 0)) as? ImageViewCollectionCell {
                cell.fromRect = dataSource.frameInWindowForItemAtIndex(self, index: selectedIndex)
        }
    }

    // Many thanks to https://github.com/damienromito/CollectionViewCustom
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let pageWidth = Float(view.frame.width + Constant.itemSpacing)
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(collectionView!.contentSize.width  )
        var newPage = Float(selectedIndex)

        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? selectedIndex + 1 : selectedIndex - 1)
            if newPage < 0 {
                newPage = 0
            }
            if (newPage > contentWidth / pageWidth) {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }

        selectedIndex = Int(newPage)
        let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
        targetContentOffset.pointee = point
    }
}

//MARK: - Collection View Cell Delegate
extension WEImageViewController: ImageViewCollectionCellDelegate {

    fileprivate func willCloseAt(_ cell: ImageViewCollectionCell) {
        if let dataSource = self.imagesDataSource {
            cell.fromRect = dataSource.frameInWindowForItemAtIndex(self, index: selectedIndex)
            let indexPath = IndexPath(item: self.selectedIndex, section: 0)
            let hidingSender = dataSource.imageViewAtIndex(self, index: indexPath.row)
            hidingSender?.isHidden = true
        } else {
            self.sender?.isHidden = true
            if let sender = sender {
                cell.fromRect = sender.superview?.convert(sender.frame, to: nil) ?? .zero
            } else {
                cell.fromRect = .zero
            }
        }
        self.rootViewController?.view.transform = CGAffineTransform.init(scaleX: Constant.scaleParentView, y: Constant.scaleParentView)
    }

    fileprivate func beginCloseAt(_ cell: ImageViewCollectionCell) {
        UIView.animate(withDuration: Constant.animationDuration, animations: {
            self.rootViewController?.view.transform = CGAffineTransform.identity
        })
    }

    fileprivate func didCloseAt(_ cell: ImageViewCollectionCell) {
        self.dismiss(animated: false, completion: {
            if let dataSource = self.imagesDataSource {
                let indexPath = IndexPath(item: self.selectedIndex, section: 0)
                let hidingSender = dataSource.imageViewAtIndex(self, index: indexPath.row)
                hidingSender?.isHidden = false
            } else {
                self.sender?.isHidden = false
            }
        })
    }


    fileprivate func didCancelCloseAt(_ cell: ImageViewCollectionCell) {
        if let dataSource = self.imagesDataSource {
            let indexPath = IndexPath(item: self.selectedIndex, section: 0)
            let hidingSender = dataSource.imageViewAtIndex(self, index: indexPath.row)
            hidingSender?.isHidden = false
        } else {
            self.sender?.isHidden = false
        }
    }

    fileprivate func adjustBacgroundOpacity(_ opacity: CGFloat) {
        view.backgroundColor = UIColor.init(white: 0, alpha: opacity)
    }
}

// MARK: - Internal Collection View Cell class implementation

fileprivate class ImageViewCollectionCell: UICollectionViewCell {

    public var fromRect = CGRect.zero {
        didSet {
            if fromRect != .zero && UIScreen.main.bounds.intersects(fromRect) {
                self.isSenderVisibleOnScreen = true
            } else {
                self.isSenderVisibleOnScreen = false
            }
        }
    }
    public var image: UIImage?
    public var url: URL?
    public var senderContentMode: UIViewContentMode?
    public weak var delegate: ImageViewCollectionCellDelegate?

    fileprivate var scrollView: UIScrollView!
    fileprivate var imageView: FLAnimatedImageView?
    fileprivate var animator : UIDynamicAnimator?
    fileprivate var currentScale: CGFloat = 1.0
    fileprivate var originalRect = CGRect.zero
    fileprivate var isSenderVisibleOnScreen = false

    //MARK: - Public methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        url = nil
        image = nil
        imageView?.image = nil
        imageView?.animatedImage = nil
    }

    func configureCell() {
        if let image = image, let imageView = imageView, let senderContentMode = senderContentMode {
            if let url = url {
                self.showLoading()
                imageView.pin_setImage(from: url, placeholderImage: image, completion: { (result) in
                    if let animateImage = result.animatedImage {
                        imageView.animatedImage = animateImage
                    } else if let staticImage = result.image {
                        imageView.image = staticImage
                    }
                    self.hideLoading()
                })
            } else {
                imageView.image = image
            }
            imageView.contentMode = senderContentMode
            imageView.frame = fromRect
            scrollView.contentSize = scrollView.frame.size
            self.updateImageViewRect()
        }
    }

    internal func updateImageViewRect() {
        // Calculate imageView expected
        guard let image = image else {
            return
        }
        let screenRect = UIScreen.main.bounds
        var imageRatio: CGFloat = 1.0
        imageRatio = image.size.width / image.size.height
        var newWidth: CGFloat = 0
        var newHeight: CGFloat = 0
        if screenRect.width / screenRect.height <= imageRatio {
            newWidth = screenRect.width
            newHeight = newWidth / imageRatio
        } else {
            newHeight = screenRect.height
            newWidth = newHeight * imageRatio
        }

        let xOffset = CGFloat.maximum(0, (screenRect.width - newWidth) / 2)
        let yOffset = CGFloat.maximum(0, (screenRect.height - newHeight) / 2)
        // swiftlint:disable line_length
        originalRect = CGRect(x: xOffset, y: yOffset, width: newWidth, height: newHeight)
        scrollView.contentSize = originalRect.size
        imageView?.frame = originalRect
    }

    internal func updateImageViewPosition() {
        guard let imageViewRect = imageView?.frame else {
            return
        }
        let screenRect = UIScreen.main.bounds
        let xOffset = CGFloat.maximum(0, (screenRect.width - imageViewRect.width) / 2)
        let yOffset = CGFloat.maximum(0, (screenRect.height - imageViewRect.height) / 2)
        // swiftlint:disable line_length
        let rect = CGRect(x: xOffset, y: yOffset, width: imageViewRect.width, height: imageViewRect.height)
        scrollView.contentSize = rect.size
        imageView?.frame = rect
    }

    //MARK: - Private methods
    internal func convertRect(_ imageView: UIImageView, fromRect: CGRect) -> CGRect {
        switch imageView.contentMode {
        case .scaleAspectFill, .scaleAspectFit:
            return calculateImageViewAspectFill(imageView, fromRect: fromRect)
        default:
            return fromRect
        }
    }

    internal func calculateImageViewAspectFill(_ imageView: UIImageView, fromRect: CGRect) -> CGRect {
        var result: CGRect = .zero
        if let imageSize = imageView.image?.size {
            let imageRatio = imageSize.width / imageSize.height
            let imageViewRatio = fromRect.width / fromRect.height
            if imageRatio > imageViewRatio {
                if imageViewRatio >= 1 {
                    result.size.height = fromRect.height
                    result.size.width = result.size.height * imageRatio
                    result.origin.x = (fromRect.width - result.size.width)/2
                } else {
                    result.size.width = fromRect.width
                    result.size.height = result.width / imageRatio
                    result.origin.y = (fromRect.height - result.size.height)/2
                }

            } else {
                if imageRatio >= 1 {
                    result.size.width = fromRect.width
                    result.size.height = result.width / imageRatio
                    result.origin.y = (fromRect.height - result.size.height)/2
                } else {
                    result.size.height = fromRect.height
                    result.size.width = result.size.height * imageRatio
                    result.origin.x = (fromRect.width - result.size.width)/2
                }
            }

        }
        return result
    }

    internal func initViews() {
        scrollView = UIScrollView(frame: contentView.bounds)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(scrollView)
        if #available(iOS 9.0, *) {
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        } else {
            // Fallback on earlier versions
        }
        self.contentView.backgroundColor = .clear
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        imageView = FLAnimatedImageView()
        imageView?.isUserInteractionEnabled = true
        imageView?.clipsToBounds = true

        scrollView.addSubview(imageView!)

        //Pinch
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureHandler(_:)))
        scrollView.addGestureRecognizer(pinchGesture)

        //Single Tap
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(_:)))
        singleTapGesture.delegate = self
        singleTapGesture.numberOfTapsRequired = 1
        scrollView?.addGestureRecognizer(singleTapGesture)

        //Double tap
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView?.addGestureRecognizer(doubleTapGesture)

        singleTapGesture.require(toFail: doubleTapGesture)

        //Pan
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        panGesture.delegate = self
        imageView?.addGestureRecognizer(panGesture)

        animator = UIDynamicAnimator(referenceView: imageView!)

        scrollView.minimumZoomScale = Constant.minimumScale
        scrollView.maximumZoomScale = Constant.maximumScale
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        currentScale = Constant.minimumScale

        self.updateImageViewRect()
    }

    internal func close() {
        delegate?.beginCloseAt(self)
        if isSenderVisibleOnScreen {
            UIView.animate(withDuration: Constant.animationDuration, animations: {
                self.delegate?.adjustBacgroundOpacity(0)
            })
            UIView.animate(withDuration: Constant.animationDuration, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                self.imageView?.frame = self.fromRect
                self.scrollView.contentSize = self.fromRect.size
            }, completion: { (finished) in
                if finished {
                    self.delegate?.didCloseAt(self)
                }
            })
        } else {
            UIView.animate(withDuration: Constant.animationDuration, animations: {
                self.delegate?.adjustBacgroundOpacity(0.0)
                self.imageView?.alpha = 0.0
            }, completion: { (finished) in
                if finished {
                    self.delegate?.didCloseAt(self)
                    self.imageView?.alpha = 1.0
                }
            })
        }
    }

    internal func resetScrollView() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.currentScale = self.scrollView.zoomScale
        }
        scrollView.setZoomScale(Constant.minimumScale, animated: true)
        CATransaction.commit()
    }

    internal func zoomToRectForScale(_ scale: CGFloat, withCenter center: CGPoint) {
        if let imageView = imageView {
            var zoomRect: CGRect = .zero
            zoomRect.size.height = imageView.frame.size.height / scale
            zoomRect.size.width  = imageView.frame.size.width / scale

            let convertedCenter: CGPoint = imageView.convert(center, from: scrollView)

            zoomRect.origin.x = convertedCenter.x - ((zoomRect.size.width / 2.0))
            zoomRect.origin.y = convertedCenter.y - ((zoomRect.size.height / 2.0))
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.currentScale = self.scrollView.zoomScale
            }
            scrollView.zoom(to: zoomRect, animated: true)
            CATransaction.commit()
        }
    }

    internal func angleOf(_ view: UIView) -> CGFloat {
        return atan2(view.transform.b, view.transform.a)
    }

    internal func showLoading() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }

    internal func hideLoading() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }

    }

}

//MARK: - Cell Scroll Delegate
extension ImageViewCollectionCell: UIScrollViewDelegate {
    internal func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            updateImageViewPosition()
            let alphaValue = scrollView.zoomScale
            self.delegate?.adjustBacgroundOpacity(alphaValue)
        }
    }

    internal func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scrollView == self.scrollView {
            scrollView.contentSize = CGSize(width: imageView?.frame.size.width ?? 0, height: imageView?.frame.size.height ?? 0)
            currentScale = scale
        }
    }

    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == self.scrollView {
            return imageView
        }
        return nil
    }
    
}

//MARK: - Cell Gesture Methods
extension ImageViewCollectionCell: UIGestureRecognizerDelegate {
    @objc internal func panGestureHandler(_ panGestureRecognizer: UIPanGestureRecognizer) {
        var yTranslation: CGFloat = 0
        var attachment : UIAttachmentBehavior?
        var lastTime = CFAbsoluteTime()
        var lastAngle: CGFloat = 0.0
        var angularVelocity: CGFloat = 0.0
        switch panGestureRecognizer.state {
        case .began:
            self.animator?.removeAllBehaviors()
            if !isSenderVisibleOnScreen {
                if let imageView = imageView {
                    let pointWithinAnimatedView = panGestureRecognizer.location(in: imageView)
                    let offset = UIOffsetMake(pointWithinAnimatedView.x - imageView.bounds.size.width / 2.0, pointWithinAnimatedView.y - imageView.bounds.size.height / 2.0)
                    let anchor = panGestureRecognizer.location(in: scrollView)
                    // create attachment behavior
                    attachment = UIAttachmentBehavior(item: imageView, offsetFromCenter: offset, attachedToAnchor: anchor)
                    attachment?.frequency = 20.0
                    // code to calculate angular velocity (seems curious that I have to calculate this myself, but I can if I have to)
                    lastTime = CFAbsoluteTimeGetCurrent()
                    lastAngle = self.angleOf(imageView)
                    weak var weakSelf = self
                    attachment?.action = {() -> Void in
                        let time = CFAbsoluteTimeGetCurrent()
                        let angle: CGFloat = weakSelf!.angleOf(imageView)
                        if time > lastTime {
                            angularVelocity = (angle - lastAngle) / CGFloat(time - lastTime)
                            lastTime = time
                            lastAngle = angle
                        }
                    }
                    self.animator?.addBehavior(attachment!)
                }
            }
            delegate?.willCloseAt(self)
        case .changed:
            if let imageView = imageView {
                if !isSenderVisibleOnScreen {
                    let anchor = panGestureRecognizer.location(in: contentView)
                    if let attachment = attachment {
                        attachment.anchorPoint = anchor
                    }
                }

                yTranslation = fabs(imageView.center.y - contentView.center.y)
                let alphaValue = 45 / yTranslation < Constant.maximumOpacity ? 45 / yTranslation : Constant.maximumOpacity
                self.delegate?.adjustBacgroundOpacity(alphaValue)
                let point = imageView.center
                let translation = panGestureRecognizer.translation(in: contentView)
                imageView.center = CGPoint(x: point.x + translation.x, y: point.y + translation.y)
                panGestureRecognizer.setTranslation(.zero, in: contentView)
            }
        case .ended, .cancelled:
            if let imageView = imageView {
                if isSenderVisibleOnScreen {
                    if fabs(panGestureRecognizer.velocity(in: contentView).y) > 1000 {
                        close()
                    } else {
                        delegate?.beginCloseAt(self)
                        UIView.animate(withDuration: 0.25, animations: {
                            self.scrollView.contentSize = self.originalRect.size
                            imageView.frame = self.originalRect
                            self.delegate?.adjustBacgroundOpacity(Constant.maximumOpacity)
                        }, completion: { (finished) in
                            if finished {
                                self.updateImageViewRect()
                                self.delegate?.didCancelCloseAt(self)
                            }
                        })
                    }
                } else {
                    let anchor = panGestureRecognizer.location(in: scrollView)
                    attachment?.anchorPoint = anchor
                    self.animator?.removeAllBehaviors()
                    let velocity = panGestureRecognizer.velocity(in: scrollView)
                    let dynamic = UIDynamicItemBehavior(items: [imageView])
                    dynamic.addLinearVelocity(velocity, for: imageView)
                    dynamic.addAngularVelocity(angularVelocity, for: imageView)
                    dynamic.angularResistance = 1.25
                    dynamic.resistance = 20
                    // when the view no longer intersects with its superview, go ahead and remove it
                    weak var weakSelf = self
                    dynamic.action = {() -> Void in
                        if !self.scrollView.bounds.intersects(imageView.frame) {
                            weakSelf?.animator?.removeAllBehaviors()
                        }
                    }
                    self.animator?.addBehavior(dynamic)

                    let gravity = UIGravityBehavior(items: [imageView])
                    gravity.magnitude = 0.7
                    self.animator?.addBehavior(gravity)
                    close()
                }
            }
        default:
            break
        }
    }

    @objc internal func pinchGestureHandler(_ pinchGestureRecignizer: UIPinchGestureRecognizer) {
        var scale = pinchGestureRecignizer.scale
        if scale != currentScale {
            return
        }
        if pinchGestureRecignizer.scale < Constant.minimumScale || pinchGestureRecignizer.scale > Constant.maximumScale {
            if pinchGestureRecignizer.scale < Constant.minimumScale {
                scale = Constant.minimumScale
            } else {
                scale = Constant.maximumScale
            }
        }
        scrollView.setZoomScale(scale, animated: true)
    }

    @objc internal func tapGestureHandler(_ tapGestureRecognizer: UITapGestureRecognizer) {
        delegate?.willCloseAt(self)
        close()
    }

    @objc internal func doubleTapHandler(_ doubleTapRecognizer: UITapGestureRecognizer) {
        if currentScale > Constant.minimumScale {
            resetScrollView()
        } else {
            zoomToRectForScale(Constant.maximumScale, withCenter: doubleTapRecognizer.location(in: scrollView))
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGesture.translation(in: scrollView)
            return fabs(translation.y) > fabs(translation.x)
        }
        return true
    }
}

extension CGRect {
    func isVisibleOnDeviceScreen() -> Bool {
        if self != .zero && UIScreen.main.bounds.intersects(self) {
            return true
        } else {
            return false
        }
    }
}
