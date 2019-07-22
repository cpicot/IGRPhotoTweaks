//
//  IGRPhotoTweakViewController.swift
//  IGRPhotoTweaks
//
//  Created by Vitalii Parovishnyk on 2/6/17.
//  Copyright © 2017 IGR Software. All rights reserved.
//

import UIKit


public protocol IGRPhotoTweakViewControllerDelegate : class {
    
    /**
     Called on image cropped.
     */
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage)
    /**
     Called on cropping image canceled
     */
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController)
}

open class IGRPhotoTweakViewController: UIViewController {
    
    //MARK: - Public VARs
    
    /*
     Image to process.
     */
    public var image: UIImage?
    
    /*
     The optional photo tweaks controller delegate.
     */
    public weak var delegate: IGRPhotoTweakViewControllerDelegate?
    
    //MARK: - Protected VARs
    
    internal var isBorderHidden: Bool = false
    
    //MARK: - Private VARs
    
    public var photoView: IGRPhotoTweakView?
    
    // MARK: - Life Cicle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.clipsToBounds = true
        
        self.setupThemes()
    }
    
    fileprivate func setupSubviews(myView: UIView) {
        if self.photoView != nil,
            let viewWithTag = self.photoView?.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
            createView(myView: myView)
        } else {
            createView(myView: myView)
        }
    }
    
    fileprivate func createView(myView: UIView){
        let photoView = IGRPhotoTweakView(frame: myView.bounds,
                                           image: self.image,
                                           customizationDelegate: self)
        photoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        photoView.tag = 100
        myView.clipsToBounds = true
        myView.addSubview(photoView)
        self.view.sendSubviewToBack(photoView)
        self.photoView = photoView
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewWillTransition(to size: CGSize,
                                          with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            self.photoView?.applyDeviceRotation()
        })
    }
    
    open func setupThemes() {
        IGRPhotoTweakView.appearance().backgroundColor = UIColor.photoTweakCanvasBackground()
        IGRPhotoContentView.appearance().backgroundColor = UIColor.clear
        IGRCropView.appearance().backgroundColor = UIColor.clear
        IGRCropGridLine.appearance().backgroundColor = UIColor.gridLine()
        IGRCropLine.appearance().backgroundColor = UIColor.cropLine()
        IGRCropCornerView.appearance().backgroundColor = UIColor.clear
        IGRCropCornerLine.appearance().backgroundColor = UIColor.cropLine()
        IGRCropMaskView.appearance().backgroundColor = UIColor.mask()
    }
    
    open func setupCropBorder(isBorderHidden: Bool = false, myView: UIView) {
        self.isBorderHidden = isBorderHidden
        setupSubviews(myView: myView)
    }
    
    // MARK: - Public
    
    public func resetView() {
        self.photoView?.resetView()
        self.stopChangeAngle()
    }
    
    public func dismissAction() {
        self.delegate?.photoTweaksControllerDidCancel(self)
    }
    
    /// cropAction do the crop computing
    /// If the expected output will be smaller than the original image,
    /// set forcedOutputSize can significantly reduce the memory consumption of this operation
    public func cropAction(forcedOutputSize: CGSize? = nil) {
        guard let photoView = self.photoView,
        let image = image else {
            return
        }
        var transform = CGAffineTransform.identity
        // translate
        let translation: CGPoint = photoView.photoTranslation
        transform = transform.translatedBy(x: translation.x, y: translation.y)
        // rotate
        transform = transform.rotated(by: photoView.radians)
        // scale
        
        let t: CGAffineTransform = photoView.photoContentView.transform
        let xScale: CGFloat = sqrt(t.a * t.a + t.c * t.c)
        let yScale: CGFloat = sqrt(t.b * t.b + t.d * t.d)
        transform = transform.scaledBy(x: xScale, y: yScale)
        
        if let fixedImage = image.cgImageWithFixedOrientation(forcedOutputSize: forcedOutputSize),
            let imageRef = fixedImage.transformedImage(transform,
                                                       zoomScale: photoView.scrollView.zoomScale,
                                                       sourceSize: image.size,
                                                       cropSize: photoView.cropView.frame.size,
                                                       imageViewSize: photoView.photoContentView.bounds.size,
                                                       forcedOutputSize: forcedOutputSize) {
            
            let image = UIImage(cgImage: imageRef)
            
            self.delegate?.photoTweaksController(self, didFinishWithCroppedImage: image)
        }
    }
    
    //MARK: - Customization
    
    open func customBorderColor() -> UIColor {
        return isBorderHidden ? UIColor.clear : UIColor.cropLine()
    }
    
    open func customBorderWidth() -> CGFloat {
        return isBorderHidden ? 0 : 1.0
    }
    
    open func customCornerBorderWidth() -> CGFloat {
        return isBorderHidden ? 0 : kCropViewCornerWidth
    }
    
    open func customCornerBorderLength() -> CGFloat {
        return isBorderHidden ? 0 : kCropViewCornerLength
    }
    
    open func customIsHighlightMask() -> Bool {
        return isBorderHidden ? false : true
    }
    
    open func customHighlightMaskAlphaValue() -> CGFloat {
        return 0.3
    }
    
    open func customCanvasHeaderHeigth() -> CGFloat {
        return kCanvasHeaderHeigth
    }
    
    open func customCropLinesCount() -> Int {
        return kCropLinesCount
    }
    
    open func customGridLinesCount() -> Int {
        return kGridLinesCount
    }
    
}
