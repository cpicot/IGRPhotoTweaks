//
//  IGRPhotoTweakViewController+AspectRatio.swift
//  Pods
//
//  Created by Vitalii Parovishnyk on 4/26/17.
//
//

import Foundation

extension IGRPhotoTweakViewController {
    public func resetAspectRect() {
        self.photoView?.resetAspectRect()
    }
    
    public func setCropAspectRect(aspect: (width: CGFloat, height: CGFloat)) {
        self.photoView?.setCropAspectRect(aspect: aspect)
    }
    
    public func lockAspectRatio(_ lock: Bool) {
        self.photoView?.lockAspectRatio(lock)
    }
    
    public func lockCropUpdate(_ lock: Bool) {
        self.photoView?.lockCropUpdate(lock)
    }
    
}
