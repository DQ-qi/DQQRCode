//
//  DQ_qrcode.swift
//  YuBeiLottery
//
//  Created by dengqi on 2017/7/5.
//  Copyright © 2017年 YuBei. All rights reserved.
//

import Foundation
import UIKit
//该是用来生成二维码的

public struct dq_QRCode {
    /**
     二维码的修正参数
     - Low:      7%
     - Medium:   15%
     - Quartile: 25%
     - High:     30%
     */
    public enum dqErrorCorrectionStyle:String {
        case Low = "L"
        case Medium = "M"
        case Quartile = "Q"
        case High = "H"
    }
    //QRCode 的Data
    public let data: Data
    
    //二维码显示的颜色 默认为黑色
    public var color = CIColor(red: 0, green: 0, blue: 0)
    
    //二维码的背景的颜色 默认为白色
    public var backgroundColor = CIColor(red: 1, green: 1, blue: 1)
    
    //二维码的图的尺寸 默认为 200x200
    public var size = CGSize(width: 200, height: 200)
    
    //二维码的修正参数 默认为High 修复参数最高
    public var dqErrorCorrection = dqErrorCorrectionStyle.High
    
    public init(_ data: Data) {
    
        self.data = data
    }
    
    public init?(_ string:String) {
        if let data = string.data(using: .isoLatin1) {
            self.data = data
        } else {
            return nil
        }
        
    }
    public init?(_ url: URL) {
        if let data = url.absoluteString.data(using:.isoLatin1 ) {
            self.data = data
        } else {
        
            return nil
        }
    }
    //核心代码
    public var ciImage: CIImage? {
        //CIQRCodeGenerator 快速响应代码(二维条码)
        guard let qrFilter = CIFilter.init(name: "CIQRCodeGenerator") else {
            return nil
        }
        //设置默认参数
        qrFilter.setDefaults()
        //inputMessage 输入数据的名称 这里inputMessage是由接口文档给出的
        qrFilter.setValue(data, forKey: "inputMessage")
        //inputCorrectionLevel 字面意思 输入源的修正参数 默认是"M"
        qrFilter.setValue(dqErrorCorrection.rawValue, forKey: "inputCorrectionLevel")//"H"的修正参数是最高的
        
        guard let colorFilter = CIFilter.init(name: "CIFalseColor") else { return nil }
    
        colorFilter.setDefaults()
        colorFilter.setValue(qrFilter.outputImage, forKey: "inputImage")
        //设置二维码的显示的颜色
        colorFilter.setValue(CIColor(red: 0, green: 0, blue: 0), forKey: "inputColor0")
        //设置二维码的背景的颜色
        colorFilter.setValue(CIColor(red: 1, green: 1, blue: 1), forKey: "inputColor1")
        let colorImage = colorFilter.outputImage
        return colorImage
    }
    public var image:UIImage? {
        guard let ciImage = ciImage else { return nil }
        
        //extent是图片的大小 基于自身的坐标
        let ciImageSize = ciImage.extent.size
        let widthRatio = size.width / ciImageSize.width
        let heightRatio = size.height / ciImageSize.height
        
        return ciImage.dq_nonInterpolatedImage(withScale: Scale(dx: widthRatio, dy: heightRatio))
    }
    
}
internal typealias Scale = (dx: CGFloat, dy: CGFloat)

internal extension CIImage {

    internal func dq_nonInterpolatedImage(withScale scale:Scale = Scale(dx: 1 , dy: 1)) -> UIImage? {
        //Creates a Quartz 2D image from a region of a Core Image image object.
        guard let cgImage = CIContext(options: nil).createCGImage(self, from: self.extent) else { return nil }
        
        let size = CGSize(width: self.extent.size.width * scale.dx, height: self.extent.size.height * scale.dy)
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        //让图片更加的清晰的
        context.interpolationQuality = .none// No interpolation.
        //
        context.translateBy(x: 0, y: size.height)
        //将二维码上下翻转方向 控制二维码的方向
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.draw(cgImage, in: context.boundingBoxOfClipPath)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        return result
    }

}
public extension UIImageView {
    
    /// Creates a new image view with the given QRCode
    ///
    /// - parameter qrCode:      The QRCode to display in the image view
    public convenience init(qrCode: dq_QRCode) {
        self.init(image: qrCode.image)
    }
    
}
