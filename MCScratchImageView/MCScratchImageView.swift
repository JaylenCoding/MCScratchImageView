//
//  MCScratchImageView.swift
//  MCScratchImageView
//
//  Created by Minecode on 2017/12/26.
//  Copyright © 2017年 Minecode. All rights reserved.
//

import UIKit

public protocol MCScratchImageViewDelegate {
    
    func mcScratchImageView(_ mcScratchImageView: MCScratchImageView, didChangeProgress progress: CGFloat)
    
}

public class MCScratchImageView: UIImageView {
    
    // MARK: Public stored properties
    public var delegate: MCScratchImageViewDelegate?
    // Determin the radius of the spot
    private(set) var spotRadius: CGFloat = 45.0
    
    // MARK: Public calculate properties
    // current scratched progress, 0.0(masked)~1.00(sharped)
    public var progress: CGFloat {
        get {
            return CGFloat(maskedMatrix.scratchedCount) / CGFloat(maskedMatrix.count)
        }
    }
    
    // MARK: Private properties
    // the martix to determine the grids of maskImage
    private var maskedMatrix: MCMatrix!
    private var imageContext: CGContext!
    private var colorSpace: CGColorSpace!
    private var touchedPoints: [CGPoint]!
    private let kSpotRadiusDefault: CGFloat = 45.0
    private let kBezierStepFactor: CGFloat = 0.2
    
    // MARK: Private caculate properties
    // the size of mask
    private var maskSize: MCSize {
        get {
            return self.maskedMatrix.size
        }
    }
    
    // MARK: - Init Function
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    public override init(image: UIImage?) {
        super.init(image: image)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = false
        
        if (self.image != nil) {
            self.reset()
        }
        touchedPoints = [CGPoint]()
    }
    
    // Reminding: This function is to reset the environments, not reset the blured image
    // so do not call it outside
    private func reset() {
        
        guard let image = self.image else {
            isUserInteractionEnabled = false
            return
        }
        
        isUserInteractionEnabled = true
        touchedPoints.removeAll()
        // initalize the image context
        let imageWidth = image.size.width * image.scale
        let imageHeight = image.size.height * image.scale
        colorSpace = CGColorSpaceCreateDeviceRGB()
        imageContext = CGContext(data: nil, width: Int(imageWidth), height: Int(imageHeight), bitsPerComponent: 8, bytesPerRow: Int(imageWidth*4), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        // draw the hole blured image
        imageContext.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        imageContext.setBlendMode(CGBlendMode.clear)
        
        // initialize the mask matrix
        self.maskedMatrix = MCMatrix(x: Int(imageWidth/(2*spotRadius)), y: Int(imageHeight/(2*spotRadius)))
    }
    
    public func setMaskImage(_ image: UIImage, spotRadius: CGFloat) {
        self.image = image
        self.spotRadius = spotRadius
        self.reset()
    }
    
    public func setMaskImage(_ image: UIImage) {
        self.setMaskImage(image, spotRadius: kSpotRadiusDefault)
        self.reset()
    }
    
    public func scratchAll() {
        // store current process
        let currentProgress = self.progress
        
        // reset masked matrix
        self.maskedMatrix.reset(status: true, scratched: maskedMatrix.count)
        
        let imageWidth = image!.size.width * image!.scale
        let imageHeight = image!.size.height * image!.scale
        imageContext = CGContext(data: nil, width: Int(imageWidth), height: Int(imageHeight), bitsPerComponent: 8, bytesPerRow: Int(imageWidth*4), space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        self.image = UIImage(cgImage: imageContext.makeImage()!)
        
        if (currentProgress != self.progress) {
            self.delegate?.mcScratchImageView(self, didChangeProgress: self.progress)
        }
    }
    
    // MARK: - Core Graphic draw funtion
    private func addTouches(_ touches: Set<UITouch>) -> UIImage {
        let imageSize = CGSize(width: self.image!.size.width*self.image!.scale, height: self.image!.size.height*self.image!.scale)
        let currentProgress = self.progress
        
        // set image context
        let ctx = imageContext!
        ctx.setStrokeColor(UIColor.clear.cgColor)
        ctx.setFillColor(UIColor.clear.cgColor)
        ctx.setLineWidth(2*spotRadius)
        ctx.setLineCap(CGLineCap.round)
        
        for touch in touches {
            ctx.beginPath()
            let touchPoint = covertCoordinateToQuartz(touch.location(in: self), imageSize: imageSize)
            
            // deal with first touch
            if (touch.phase == .began) {
                touchedPoints.removeAll()
                touchedPoints.append(touchPoint)
                touchedPoints.append(touchPoint)
                
                // if current is touch begin, just add an ellipse
                let ellipseRect = CGRect(x: touchPoint.x-spotRadius, y: touchPoint.y-spotRadius, width: spotRadius*2, height: spotRadius*2)
                ctx.addEllipse(in: ellipseRect)
                ctx.fillPath()
                
                updateGrid(withPointX: ellipseRect.origin.x, pointY: ellipseRect.origin.y)
            }
            else if (touch.phase == .moved) {
                touchedPoints.append(touchPoint)
                
                // use touchpoints to draw a bezier path
                // using CGContextAddCurveToPoint with 4 point
                while (self.touchedPoints.count >= 4) {
                    var points: [CGPoint] = [CGPoint](repeating: CGPoint(), count: 4)
                    points[0] = touchedPoints[1]
                    points[1] = touchedPoints[0]
                    points[2] = touchedPoints[3]
                    points[3] = touchedPoints[2]
                    
                    let centerMargin: CGFloat = sqrt(pow(points[3].x-points[0].x, 2) + pow(points[3].y-points[0].y, 2))
                    var xPointCursor: CGFloat = 0.0
                    var yPointCursor: CGFloat = 0.0
                    
                    // scale the to other point
                    xPointCursor = (points[0].x - points[1].x) - (points[0].x - points[3].x)
                    yPointCursor = (points[0].y - points[1].y) - (points[0].y - points[3].y)
                    points[1] = formPointToScale(x: xPointCursor, y: yPointCursor)
                    points[1] = formPoint(points[1], margin: centerMargin, factor: kBezierStepFactor)
                    points[1].x += points[0].x
                    points[1].y += points[0].y
                    
                    xPointCursor = (points[3].x - points[2].x) - (points[3].x - points[0].x)
                    yPointCursor = (points[3].y - points[2].y) - (points[3].y - points[0].y)
                    points[2] = formPointToScale(x: xPointCursor, y: yPointCursor)
                    points[2] = formPoint(points[2], margin: centerMargin, factor: kBezierStepFactor)
                    points[2].x += points[3].x
                    points[2].y += points[3].y
                    
                    ctx.move(to: points[0])
                    ctx.addCurve(to: points[1], control1: points[2], control2: points[3])
                    
                    touchedPoints.remove(at: 0)
                }
                
                ctx.strokePath()
                let preTouchPoint = covertCoordinateToQuartz(touch.previousLocation(in: self), imageSize: imageSize)
                updateGrid(withBeginPoint: touchPoint, endPoint: preTouchPoint)
            }
            
        }
        
        if (currentProgress != self.progress) {
            self.delegate?.mcScratchImageView(self, didChangeProgress: self.progress)
        }
        
        let cgImage = ctx.makeImage()
        let resImage = UIImage(cgImage: cgImage!)
        return resImage
    }
    
    private func  formPointToScale(x: CGFloat, y: CGFloat) -> CGPoint {
        let len = sqrt(x*x + y*y)
        if (len == 0) {
            return CGPoint.zero
        }
        return CGPoint(x: x/len, y: y/len)
    }
    
    private func formPoint(_ point: CGPoint, margin: CGFloat, factor: CGFloat) -> CGPoint {
        var res = point
        res.x *= margin
        res.y *= margin
        res.x *= factor
        res.y *= factor
        return res
    }
    
    // convert UI coordinate to Quartz coordinate
    private func covertCoordinateToQuartz(_ point: CGPoint, imageSize: CGSize) -> CGPoint {
        return CGPoint(x: imageSize.width * point.x / self.bounds.size.width, y: imageSize.height * (self.bounds.height-point.y) / self.bounds.size.height)
    }
    
    // MARK: - touch event handler
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (self.image == nil) {return}
        self.image = self.addTouches(touches)
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (self.image == nil) {return}
        self.image = self.addTouches(touches)
        
    }
    
    // MARK: - Grid filled function
    // Reminder: This function is to update the data of matrix
    // The draw function has written above
    private func updateGrid(withPointX x: CGFloat, pointY y: CGFloat) {
        
        let imageWidth = image!.size.width * image!.scale
        let imageHeight = image!.size.height * image!.scale
        let xCursor = min(imageWidth-1, max(0, x))
        let yCursor = min(imageHeight-1, max(0, y))
        let xIdx = Int( xCursor * CGFloat(maskedMatrix.size.x) / imageWidth)
        let yIdx = Int( yCursor * CGFloat(maskedMatrix.size.y) / imageHeight)
        
        if (maskedMatrix.statusForGrid(x: xIdx, y: yIdx) == false) {
            maskedMatrix.setGrid(x: xIdx, y: yIdx, forStatus: true)
        }
        
    }
    
    private func updateGrid(withBeginPoint begin: CGPoint, endPoint end: CGPoint) {
        
        let imageWidth = image!.size.width * image!.scale
        let imageHeight = image!.size.height * image!.scale
        
        var idx = begin
        let kIncreaseStepX = (begin.x < end.x ? 1 : -1) * imageWidth / CGFloat(maskSize.x);
        let kIncreaseStepY = (begin.y < end.y ? 1 : -1) * imageHeight / CGFloat(maskSize.y);
        
        while (idx.x>=min(begin.x, end.x) && idx.x<=max(begin.x, end.x) && idx.y>=min(begin.y, end.y) && idx.y<=max(begin.y, end.y)) {
            updateGrid(withPointX: idx.x, pointY: idx.y)
            
            idx.x += kIncreaseStepX
            idx.y += kIncreaseStepY
        }
        updateGrid(withPointX: idx.x, pointY: idx.y)
        
    }
}


// MARK: - The matrix struct that determine the mask grids
fileprivate struct MCMatrix {
    
    // stored properties
    private(set) var size: MCSize
    private(set) var gridScratched: [Bool]!
    
    // calculate properties
    var count: Int {
        get {
            return size.x*size.y
        }
    }
    private(set) var scratchedCount: Int
    
    init(_ size: MCSize) {
        self.size = size
        scratchedCount = 0
        gridScratched = [Bool](repeating: false, count: self.count)
    }
    
    init(x: Int, y: Int) {
        self.init(MCSize(x: x, y: y))
    }
    
    public func statusForGrid(x: Int, y: Int) -> Bool {
        if (x*y >= count) {return true}
        return gridScratched[x + size.x*y]
    }
    
    public mutating func setGrid(x: Int, y: Int, forStatus status: Bool) {
        if (x*y >= count) {return}
        if (gridScratched[x + size.x*y] != status) {
            scratchedCount += status ? 1 : -1
            gridScratched[x + size.x*y] = status
        }
    }
    
    public mutating func reset( status: Bool = false, scratched: Int = 0) {
        gridScratched = [Bool](repeating: status, count: self.count)
        scratchedCount = scratched
    }
    
}

// MARK: - The Size struct
fileprivate struct MCSize {
    
    public var x: Int
    public var y: Int
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
}
fileprivate typealias MCPoint = MCSize
