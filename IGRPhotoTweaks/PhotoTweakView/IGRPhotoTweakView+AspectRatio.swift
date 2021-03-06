//
//  IGRPhotoTweakView+AspectRatio.swift
//  Pods
//
//  Created by Vitalii Parovishnyk on 4/26/17.
//
//

import Foundation

extension IGRPhotoTweakView {
    public func resetAspectRect() {
        self.cropView.frame = CGRect(x: .zero,
                                     y: .zero,
                                     width: self.originalSize.width,
                                     height: self.originalSize.height)
        self.cropView.center = self.scrollView.center
        self.cropView.resetAspectRect()
        
        self.cropViewDidStopCrop(self.cropView)
    }
    
    public func setCropAspectRect(aspect: (width: CGFloat,
        height: CGFloat)) {
        self.cropView.setCropAspectRect(aspect: aspect,
                                        maxSize: self.originalSize)
        self.cropView.center = self.scrollView.center
        
        self.cropViewDidStopCrop(self.cropView)
    }
    
    public func lockAspectRatio(_ lock: Bool) {
        self.cropView.lockAspectRatio(lock)
    }
    
    public func lockCropUpdate(_ lock: Bool) {
        self.cropView.lockUpdateCrop(lock)
    }
}
