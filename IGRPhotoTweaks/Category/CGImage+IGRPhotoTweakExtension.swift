//
//  CGImage+IGRPhotoTweakExtension.swift
//  Pods
//
//  Created by Vitalii Parovishnyk on 4/26/17.
//
//

import Foundation

extension CGImage {
    
    func transformedImage(_ transform: CGAffineTransform,
                          zoomScale: CGFloat,
                          sourceSize: CGSize,
                          cropSize: CGSize,
                          imageViewSize: CGSize) -> CGImage? {
        let expectedWidth = floor(sourceSize.width / imageViewSize.width * cropSize.width) / zoomScale
        let expectedHeight = floor(sourceSize.height / imageViewSize.height * cropSize.height) / zoomScale
        let outputSize = CGSize(width: expectedWidth, height: expectedHeight)
        let bitmapBytesPerRow = 0
      
        var bitmapInfo = self.bitmapInfo
        // Fix alpha channel issues if necessary
        let alpha = (bitmapInfo.rawValue & CGBitmapInfo.alphaInfoMask.rawValue)
      
        if alpha == CGImageAlphaInfo.none.rawValue {
          bitmapInfo.remove(.alphaInfoMask)
          bitmapInfo = CGBitmapInfo(rawValue: bitmapInfo.rawValue |
            CGImageAlphaInfo.noneSkipFirst.rawValue)
        } else if !(alpha == CGImageAlphaInfo.noneSkipFirst.rawValue) ||
          !(alpha == CGImageAlphaInfo.noneSkipLast.rawValue) {
          bitmapInfo.remove(.alphaInfoMask)
          bitmapInfo = CGBitmapInfo(rawValue: bitmapInfo.rawValue |
            CGImageAlphaInfo.premultipliedFirst.rawValue)
        }
      
        let context = CGContext(data: nil,
                                width: Int(outputSize.width),
                                height: Int(outputSize.height),
                                bitsPerComponent: self.bitsPerComponent,
                                bytesPerRow: bitmapBytesPerRow,
                                space: self.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: bitmapInfo.rawValue)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(CGRect(x: .zero,
                             y: .zero,
                             width: outputSize.width,
                             height: outputSize.height))
        
        var uiCoords = CGAffineTransform(scaleX: outputSize.width / cropSize.width,
                                         y: outputSize.height / cropSize.height)
        uiCoords = uiCoords.translatedBy(x: cropSize.width.half, y: cropSize.height.half)
        uiCoords = uiCoords.scaledBy(x: 1.0, y: -1.0)
        
        context?.concatenate(uiCoords)
        context?.concatenate(transform)
        context?.scaleBy(x: 1.0, y: -1.0)
        let rect = CGRect(x: (-imageViewSize.width.half),
                          y: (-imageViewSize.height.half),
                          width: imageViewSize.width,
                          height: imageViewSize.height)
        context?.draw(self,
                      in: rect)
        
        let result = context?.makeImage()
        
        return result
    }
}
