//
//  IGRPhotoTweakView.swift
//  IGRPhotoTweaks
//
//  Created by Vitalii Parovishnyk on 2/6/17.
//  Copyright © 2017 IGR Software. All rights reserved.
//

import UIKit

public class IGRPhotoTweakView: UIView {
    
    //MARK: - Public VARs
    
    public weak var customizationDelegate: IGRPhotoTweakViewCustomizationDelegate?
    
    private(set) lazy var cropView: IGRCropView! = { [unowned self] by in
        
        let cropView = IGRCropView(frame: self.scrollView.frame,
                                   cornerBorderWidth:self.cornerBorderWidth(),
                                   cornerBorderLength:self.cornerBorderLength(),
                                   cropLinesCount:self.cropLinesCount(),
                                   gridLinesCount:self.gridLinesCount())
        cropView.center = self.scrollView.center
        
        cropView.layer.borderColor = self.borderColor().cgColor
        cropView.layer.borderWidth = self.borderWidth()
        self.addSubview(cropView)
        
        return cropView
        }(())
    
    public private(set) lazy var photoContentView: IGRPhotoContentView! = { [unowned self] by in
        
        let photoContentView = IGRPhotoContentView(frame: self.scrollView.bounds)
        photoContentView.isUserInteractionEnabled = true
        self.scrollView.addSubview(photoContentView)
        
        return photoContentView
        }(())
    
    public var photoTranslation: CGPoint {
        get {
            let rect: CGRect = self.photoContentView.convert(self.photoContentView.bounds,
                                                             to: self)
            let point = CGPoint(x: (rect.origin.x + rect.size.width.half),
                                y: (rect.origin.y + rect.size.height.half))
            let zeroPoint = CGPoint(x: self.frame.width.half, y: self.centerY)
            
            return CGPoint(x: (point.x - zeroPoint.x), y: (point.y - zeroPoint.y))
        }
    }
    
    //MARK: - Private VARs
    
    internal var radians: CGFloat = .zero
    fileprivate var photoContentOffset: CGPoint = .zero
    
    internal lazy var scrollView: IGRPhotoScrollView! = { [unowned self] by in
        
        let maxBounds = self.maxBounds()
        self.originalSize = maxBounds.size
        
        let scrollView = IGRPhotoScrollView(frame: maxBounds)
        scrollView.center = CGPoint(x: self.frame.width.half, y: self.centerY)
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(scrollView)
        
        return scrollView
        }(())
    
    internal weak var image: UIImage?
    internal var originalSize: CGSize = .zero
    
    internal var manualZoomed = false
    internal var manualMove   = false
    
    // masks
    internal var topMask:    IGRCropMaskView!
    internal var leftMask:   IGRCropMaskView!
    internal var bottomMask: IGRCropMaskView!
    internal var rightMask:  IGRCropMaskView!
    
    // constants
    fileprivate var maximumCanvasSize: CGSize?
    fileprivate var originalPoint: CGPoint?
    internal var centerY: CGFloat = 0
    
    // MARK: - Life Cicle
    
    init(frame: CGRect,
         image: UIImage?,
         customizationDelegate: IGRPhotoTweakViewCustomizationDelegate) {
        super.init(frame: frame)
        
        self.image = image
        
        self.customizationDelegate = customizationDelegate
        
        setupScrollView()
        setupCropView()
        setupMasks()
        
        self.originalPoint = self.convert(self.scrollView.center, to: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.originalSize = self.maxBounds().size
    }
    
    //MARK: - Public FUNCs
    
    public func setMaxZoomScale(_ scale: CGFloat) {
        self.scrollView.maximumZoomScale = scale
    }
    
    public func resetView() {
        let animation: (() -> Void) = { () -> Void in
            self.radians = CGFloat.zero
            self.scrollView.transform = CGAffineTransform.identity
            self.scrollView.center = CGPoint(x: self.frame.width.half,
                                             y: self.centerY)
            self.scrollView.bounds = CGRect(x: .zero,
                                            y: .zero,
                                            width: self.originalSize.width,
                                            height: self.originalSize.height)
            self.scrollView.minimumZoomScale = 1
            self.scrollView.setZoomScale(1, animated: false)
            
            self.cropView.frame = self.scrollView.frame
            self.cropView.center = self.scrollView.center
        }
        UIView.animate(withDuration: kAnimationDuration,
                       animations: animation)
    }
    
    public func applyDeviceRotation() {
        self.resetView()
        
        self.scrollView.center = CGPoint(x: self.frame.width.half,
                                         y: self.centerY)
        self.scrollView.bounds = CGRect(x: .zero,
                                        y: .zero,
                                        width: self.originalSize.width,
                                        height: self.originalSize.height)
        
        self.cropView.frame = self.scrollView.frame
        self.cropView.center = self.scrollView.center
        
        // Update 'photoContent' frame and set the image.
        self.scrollView.photoContentView.frame = .init(x: .zero,
                                                       y: .zero,
                                                       width: self.cropView.frame.width,
                                                       height: self.cropView.frame.height)
        self.scrollView.photoContentView.image = self.image
        
        updatePosition()
    }
    
    //MARK: - Private FUNCs
    
    fileprivate func maxBounds() -> CGRect {
        // scale the image
        let maxCanvasSize =
            CGSize(width: (kMaximumCanvasWidthRatio * self.frame.size.width),
                   height: (kMaximumCanvasHeightRatio * self.frame.size.height - self.canvasHeaderHeigth()))
        
        self.centerY = maxCanvasSize.height.half + self.canvasHeaderHeigth()
        
        let width = self.image?.size.width ?? 0
        let height = self.image?.size.height ?? 0
        let scaleX: CGFloat = width / maxCanvasSize.width
        let scaleY: CGFloat = height / maxCanvasSize.height
        let scale: CGFloat = max(scaleX, scaleY)
        self.maximumCanvasSize = maxCanvasSize
        let bounds = CGRect(x: .zero,
                            y: .zero,
                            width: width / scale,
                            height: height / scale)
        
        return bounds
    }
    
    internal func updatePosition() {
        // position scroll view
        let width: CGFloat =
            abs(cos(self.radians)) * self.cropView.frame.size.width +
                abs(sin(self.radians)) * self.cropView.frame.size.height
        let height: CGFloat =
            abs(sin(self.radians)) * self.cropView.frame.size.width +
                abs(cos(self.radians)) * self.cropView.frame.size.height
        let center: CGPoint = self.scrollView.center
        let contentOffset: CGPoint = self.scrollView.contentOffset
        let contentOffsetCenter =
            CGPoint(x: (contentOffset.x + self.scrollView.bounds.size.width.half),
                    y: (contentOffset.y + self.scrollView.bounds.size.height.half))
        self.scrollView.bounds = CGRect(x: .zero,
                                        y: .zero,
                                        width: width,
                                        height: height)
        let newContentOffset =
            CGPoint(x: (contentOffsetCenter.x - self.scrollView.bounds.size.width.half),
                    y: (contentOffsetCenter.y - self.scrollView.bounds.size.height.half))
        self.scrollView.contentOffset = newContentOffset
        self.scrollView.center = center
        
        // scale scroll view
        let shouldScale: Bool =
            self.scrollView.contentSize.width / self.scrollView.bounds.size.width <= 1.0 ||
            self.scrollView.contentSize.height / self.scrollView.bounds.size.height <= 1.0
        if !self.manualZoomed || shouldScale {
            let zoom = self.scrollView.zoomScaleToBound()
            self.scrollView.setZoomScale(zoom, animated: false)
            self.scrollView.minimumZoomScale = zoom
            self.manualZoomed = false
        }
        
        self.scrollView.checkContentOffset()
    }
}
