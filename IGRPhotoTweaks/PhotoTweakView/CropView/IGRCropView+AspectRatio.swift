//
//  IGRCropView+AspectRatio.swift
//  Pods
//
//  Created by Vitalii Parovishnyk on 4/26/17.
//
//

import Foundation

extension IGRCropView {
    
    public func resetAspectRect() {
        self.aspectRatioWidth = self.frame.size.width
        self.aspectRatioHeight = self.frame.size.height
    }
    
    public func setCropAspectRect(aspect: (width: CGFloat, height: CGFloat), maxSize: CGSize) {
        self.aspectRatioWidth = aspect.width
        self.aspectRatioHeight = aspect.height
        
        var size = maxSize
        let mW = size.width / self.aspectRatioWidth
        let mH = size.height / self.aspectRatioHeight
        
        if mH < mW {
            size.width = size.height / self.aspectRatioHeight * self.aspectRatioWidth
        }
        else if mW < mH {
            size.height = size.width / self.aspectRatioWidth * self.aspectRatioHeight
        }
        
        let x = (self.frame.size.width - size.width).half
        let y = (self.frame.size.height - size.height).half
        
        self.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
    }
    
    public func lockAspectRatio(_ lock: Bool) {
        resetAspectRect()
        self.isAspectRatioLocked = lock
    }
    
    public func lockUpdateCrop(_ lock: Bool) {
        resetAspectRect()
        self.isCropUpdateLocked = lock
    }
}
