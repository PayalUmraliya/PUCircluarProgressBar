//
//  PUWAppStatusProgressIndicator.swift
//  PUWhatsAppStatusProgressBar
//
//  Created by Payal on 09/01/24.
//

import Foundation
import UIKit

typealias Degrees = Double
typealias Radians = CGFloat
extension Date
{
    func getDaysInMonth() -> Int
    {
            let calendar = Calendar.current
            let dateComponents = DateComponents(year: calendar.component(.year, from: self), month: calendar.component(.month, from: self))
            let date = calendar.date(from: dateComponents)!
            let range = calendar.range(of: .day, in: .month, for: date)!
            let numDays = range.count
            return numDays
    }
}
// Circular Slider

struct PUCircularSliderSettings {
    
     var minimumValue: Float = 0
     var maximumValue: Float = 500
    var lineWidth:CGFloat = 5
    var ringColor: UIColor = UIColor.lightGray
    var circleFillColor:UIColor = UIColor.clear
    var puNormalColor: UIColor = UIColor.darkGray
    var puHighlightedColor: UIColor = UIColor.green
    var highlighted: Bool = true
    var ThumbIndicatorRadius: CGFloat = 20
    var radiansOffset: CGFloat = 0
    var isPlainColor:Bool = false
    var gradientColors:[UIColor] = [.yellow,.orange,.white]
}

open class PUCircularSlider: UIView {

    fileprivate var backgroundRingLayer = CAShapeLayer()
    fileprivate var progressRingLayer = CAShapeLayer()
    fileprivate var thumbIndicatorLayer = CAShapeLayer()
    fileprivate var defaultValue: Float = 0
    fileprivate var defaultThumbIndicatorAngle: CGFloat = 0
    fileprivate var startAngle: CGFloat {
        return -CGFloat.pi / 2 + settings.radiansOffset
    }
    fileprivate var endAngle: CGFloat {
        return 3 * CGFloat(Double.pi / 2) - settings.radiansOffset
    }
    fileprivate var angleRange: CGFloat {
        return endAngle - startAngle
    }
    fileprivate var valueRange: Float {
        return settings.maximumValue - settings.minimumValue
    }
    fileprivate var arcCenter: CGPoint {
        return CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    fileprivate var arcRadius: CGFloat {
        return min(frame.width,frame.height) / 2 - settings.lineWidth / 2
    }
    fileprivate var calculatedValue: Float {
        return (value - settings.minimumValue) / (settings.maximumValue - settings.minimumValue)
    }
    fileprivate var ThumbIndicatorAngle: CGFloat {
        return CGFloat(calculatedValue) * angleRange + startAngle
    }
    fileprivate var ThumbIndicatorMidAngle: CGFloat {
        let angleRange = (startAngle - endAngle).truncatingRemainder(dividingBy: 2 * .pi)
        let normalizedEndAngle = (endAngle + angleRange).truncatingRemainder(dividingBy: 2 * .pi)
        return (2 * .pi + normalizedEndAngle) / 2
    }

    fileprivate var ThumbIndicatorRotationTransform: CATransform3D {
        return CATransform3DMakeRotation(ThumbIndicatorAngle, 0.0, 0.0, 1)
    }
    private let gradientLayer: CAGradientLayer = {
           let gradientLayer = CAGradientLayer()
           gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.8, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
           return gradientLayer
       }()
    var settings: PUCircularSliderSettings = PUCircularSliderSettings(){
        didSet {
            settingUp()
            setNeedsDisplay()
        }
    }
    open var value: Float {
        get {
            return defaultValue
        }
        set {
            defaultValue = min(settings.maximumValue, max(settings.minimumValue, newValue))
        }
    }
 
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        settingUp()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        settingUp()
    }

    override open func draw(_ rect: CGRect) {
        print("drawRect")
        backgroundRingLayer.bounds = bounds
        progressRingLayer.bounds = bounds
        thumbIndicatorLayer.bounds = bounds
        backgroundRingLayer.position = arcCenter
        progressRingLayer.position = arcCenter
        thumbIndicatorLayer.position = arcCenter
        backgroundRingLayer.path = getCirclePath()
        progressRingLayer.path = getCirclePath()
        thumbIndicatorLayer.path = getThumbIndicatorPath()
        setValue(value, animated: false)
    }
    
    
    fileprivate func getCirclePath() -> CGPath {
        return UIBezierPath(arcCenter: arcCenter,
                            radius: arcRadius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true).cgPath
    }
    
    fileprivate func getThumbIndicatorPath() -> CGPath {
        return UIBezierPath(roundedRect:
                                CGRect(x: arcCenter.x + arcRadius - settings.ThumbIndicatorRadius / 2, y: arcCenter.y - settings.ThumbIndicatorRadius / 2, width: settings.ThumbIndicatorRadius, height: settings.ThumbIndicatorRadius),
                            cornerRadius: settings.ThumbIndicatorRadius / 2).cgPath
    }
    
    
    // MARK: - settingUp
    fileprivate func settingUp() {
        clipsToBounds = false
        self.value = 0
        settingUpBackgroundLayer()
        settingUpProgressLayer()
        settingUpthumbIndicatorLayer()
    }
    
    fileprivate func settingUpBackgroundLayer() {
        backgroundRingLayer.frame = bounds
        layer.addSublayer(backgroundRingLayer)
        groomBackgroundLayer()
    }
    
    fileprivate func settingUpProgressLayer() {
        progressRingLayer.frame = bounds
        progressRingLayer.strokeEnd = 0
        layer.addSublayer(progressRingLayer)
        groomProgressLayer()
    }
    
    fileprivate func settingUpthumbIndicatorLayer() {
        thumbIndicatorLayer.frame = bounds
        thumbIndicatorLayer.position = arcCenter
        thumbIndicatorLayer.path = self.getThumbIndicatorPath()
        thumbIndicatorLayer.fillColor = UIColor.blue.cgColor
        layer.addSublayer(thumbIndicatorLayer)
        groomThumbIndicatorLayer()
    }
    
    fileprivate func groomBackgroundLayer() {
        backgroundRingLayer.lineWidth = settings.lineWidth
        backgroundRingLayer.fillColor = settings.circleFillColor.cgColor
        backgroundRingLayer.strokeColor = settings.ringColor.cgColor
        backgroundRingLayer.lineCap = .round
    }
    
    fileprivate func groomProgressLayer() {
        progressRingLayer.lineWidth = settings.lineWidth
        progressRingLayer.fillColor = UIColor.clear.cgColor
        progressRingLayer.strokeColor = settings.highlighted ? settings.puHighlightedColor.cgColor : settings.puNormalColor.cgColor
        progressRingLayer.lineCap = .round
        self.setUpGradientLayer(maskedLayer: progressRingLayer )
    }
    
    fileprivate func groomThumbIndicatorLayer() {
        thumbIndicatorLayer.lineWidth = 2
        thumbIndicatorLayer.fillColor = settings.highlighted ? settings.puHighlightedColor.cgColor : settings.puNormalColor.cgColor
        thumbIndicatorLayer.strokeColor = UIColor.white.cgColor
       
    }
    func setUpGradientLayer(maskedLayer:CAShapeLayer){
            gradientLayer.frame = bounds
            gradientLayer.colors = settings.gradientColors.map { $0.cgColor }
            layer.addSublayer(gradientLayer)
            gradientLayer.mask = maskedLayer
    }
    // MARK: - update
    open func setValue(_ value: Float, animated: Bool) {
        self.value =  value
        setStrokeEnd(animated: animated)
        setThumbIndicatorRotation(animated: animated)
    }
    
    fileprivate func setStrokeEnd(animated: Bool) {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = animated ? 0.66 : 0
        strokeAnimation.repeatCount = 1
        strokeAnimation.fromValue = progressRingLayer.strokeEnd
        strokeAnimation.toValue = CGFloat(calculatedValue)
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.fillMode = CAMediaTimingFillMode.removed
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        progressRingLayer.add(strokeAnimation, forKey: "strokeAnimation")
        progressRingLayer.strokeEnd = CGFloat(calculatedValue)
        CATransaction.commit()
    }
    
    fileprivate func setThumbIndicatorRotation(animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.duration = animated ? 0.66 : 0
        animation.values = [defaultThumbIndicatorAngle, ThumbIndicatorAngle]
        thumbIndicatorLayer.add(animation, forKey: "ThumbIndicatorRotationAnimation")
        thumbIndicatorLayer.transform = ThumbIndicatorRotationTransform
        
        CATransaction.commit()
        
        defaultThumbIndicatorAngle = ThumbIndicatorAngle
    }
    
    func cancelAnimation() {
        progressRingLayer.removeAllAnimations()
        thumbIndicatorLayer.removeAllAnimations()
    }
    
}

//WHATSAPP STORY UI
struct PUWAppStatusProgressIndicatorSettings {
    
    var segmentsCount: Int = 4
    var colorSegementCount = 4
    var segmentWidth: CGFloat = 2
    var spaceBetweenSegments: Degrees = 10
    var targetSegementNumber = 12
    var targetSegmentColor: UIColor = UIColor.green
    var segmentColor: UIColor = UIColor.red
    var defaultSegmentColor: UIColor = UIColor.gray
    var segmentBorderType: CAShapeLayerLineCap = .round
    var animationDuration: Double = 0.5
    var isStaticSegmentsVisible = true
    var startPointPadding: CGFloat = 0
}

class PUWAppStatusProgressIndicator: UIView {
    
    private var segments: [CAShapeLayer] = []
    private var staticSegments: [CAShapeLayer] = []
    private var value: Radians = 0.0
    private var activeSegment: Int = 0
    var settings: PUWAppStatusProgressIndicatorSettings = PUWAppStatusProgressIndicatorSettings() {
        didSet {
            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.setup()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func toRadians(_ value: Degrees) -> Radians {
        return CGFloat(value) * .pi / CGFloat(180)
    }
    
    private func setup() {
        drawDefaultSegments()
        drawLiveSegmentsWithColorVariation()
    }
    private func drawLiveSegmentsWithColorVariation() {
        segments = []
        let emptySpace = Double(settings.segmentsCount) * settings.spaceBetweenSegments
        let emptySpaceInRadians = toRadians(emptySpace)
        let summedSpaceForSegments = 2 * Radians.pi - emptySpaceInRadians
        let spaceCorrelation = toRadians(Degrees((settings.segmentWidth)))
        let segmentSpace = summedSpaceForSegments / Radians(settings.segmentsCount) - spaceCorrelation
        let halfSpace = toRadians(settings.spaceBetweenSegments) / 2 + spaceCorrelation / 2
        let startPointPaddingInRadians = toRadians(Degrees(settings.startPointPadding))
        
        for segmentIndex in 0..<settings.segmentsCount {
            let index = CGFloat(segmentIndex)
            let startPoint = startPointPaddingInRadians + segmentSpace * index + halfSpace + 2 * halfSpace * index
            let endPoint = startPoint + segmentSpace
            let segmentShape = getSegment(startAngle: startPoint,
                                          endInAngle: endPoint,
                                          color: decideSegemntColorOfIdx(idx: segmentIndex),
                                          strokeEnd: 0)
            segments.append(segmentShape)
            self.layer.addSublayer(segmentShape)
        }
    }
    func decideSegemntColorOfIdx(idx:Int) -> UIColor
    {
        if idx < settings.colorSegementCount && idx != settings.targetSegementNumber
        {
            return settings.segmentColor
        }
        else if idx == settings.targetSegementNumber
        {
            return settings.colorSegementCount - 1 > settings.targetSegementNumber ? settings.segmentColor : settings.targetSegmentColor
        }
        else
        {
            return idx == settings.targetSegementNumber ? settings.targetSegmentColor :  settings.defaultSegmentColor
        }
        //below this logic is for set yellow color for all case
//        if (idx < settings.colorSegementCount && idx != settings.targetSegementNumber)
//        {
//            return settings.segmentColor
//        }
//        else if idx == settings.targetSegementNumber
//        {
//            return settings.targetSegmentColor
//        }
//        else
//        {
//            return settings.defaultSegmentColor
//        }
    }
    private func drawLiveSegments() {
        segments = []
        let emptySpace = Double(settings.segmentsCount) * settings.spaceBetweenSegments
        let emptySpaceInRadians = toRadians(emptySpace)
        let summedSpaceForSegments = 2 * Radians.pi - emptySpaceInRadians
        let spaceCorrelation = toRadians(Degrees((settings.segmentWidth)))
        let segmentSpace = summedSpaceForSegments / Radians(settings.segmentsCount) - spaceCorrelation
        let halfSpace = toRadians(settings.spaceBetweenSegments) / 2 + spaceCorrelation / 2
        let startPointPaddingInRadians = toRadians(Degrees(settings.startPointPadding))
        
        for segmentIndex in 0..<settings.segmentsCount {
            let index = CGFloat(segmentIndex)
            let startPoint = startPointPaddingInRadians + segmentSpace * index + halfSpace + 2 * halfSpace * index
            let endPoint = startPoint + segmentSpace
            let segmentShape = getSegment(startAngle: startPoint,
                                          endInAngle: endPoint,
                                          color: settings.segmentColor,
                                          strokeEnd: 0)
            segments.append(segmentShape)
            self.layer.addSublayer(segmentShape)
        }
    }
    
    private func drawDefaultSegments() {
        staticSegments = []
        guard settings.isStaticSegmentsVisible else {
            return
        }
        let spaceCorrelation = toRadians(Degrees((settings.segmentWidth)))
        let emptySpace = Double(settings.segmentsCount) * settings.spaceBetweenSegments
        let emptySpaceInRadians = toRadians(emptySpace)
        let summedSpaceForSegments = 2 * Radians.pi - emptySpaceInRadians
        let segmentSpace = summedSpaceForSegments / Radians(settings.segmentsCount) - spaceCorrelation
        let halfSpace = toRadians(settings.spaceBetweenSegments) / 2 + spaceCorrelation / 2
        let startPointPaddingInRadians = toRadians(Degrees(settings.startPointPadding))
        
        for segmentIndex in 0..<settings.segmentsCount {
            let index = CGFloat(segmentIndex)
            let startPoint = startPointPaddingInRadians + segmentSpace * index + halfSpace + 2 * halfSpace * index
            let endPoint = startPoint + segmentSpace
            let segmentShape = getSegment(startAngle: startPoint,
                                          endInAngle: endPoint,
                                          color: segmentIndex == settings.targetSegementNumber ? settings.targetSegmentColor : settings.defaultSegmentColor,
                                          strokeEnd: 1)
            staticSegments.append(segmentShape)
            self.layer.addSublayer(segmentShape)
            if settings.colorSegementCount > settings.targetSegementNumber + 1
            {
                let segmentShape = getSegment(startAngle: startPoint,
                                              endInAngle: endPoint,
                                              color: settings.defaultSegmentColor,
                                              strokeEnd: 1)
                staticSegments.append(segmentShape)
                self.layer.addSublayer(segmentShape)
            }
        }
    }
    
    private func getSegment(startAngle: Radians,
                            endInAngle: Radians,
                            color: UIColor,
                            strokeEnd: CGFloat) -> CAShapeLayer {
        let centre = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let beizerPath = UIBezierPath(arcCenter: centre,
                                      radius: bounds.height / 2 - settings.segmentWidth / 2,
                                      startAngle: startAngle,
                                      endAngle: endInAngle,
                                      clockwise: true)
        let segmentLayer = CAShapeLayer()
        segmentLayer.path = beizerPath.cgPath
        segmentLayer.fillColor = UIColor.clear.cgColor
        segmentLayer.strokeEnd = strokeEnd
        segmentLayer.lineWidth = settings.segmentWidth
        segmentLayer.lineCap = settings.segmentBorderType
        segmentLayer.strokeColor = color.cgColor
        segmentLayer.strokeStart = 0.0
        return segmentLayer
    }

    private func updateProgressInLayer(progressLayer: CAShapeLayer,
                                       percent: CGFloat,
                                       segmentIndex: Int) {
        CATransaction.begin()
        self.activeSegment = segmentIndex
        let oldValue = value
        let newValue = percent
        value = newValue
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = oldValue
        animation.toValue = newValue
        animation.duration = settings.animationDuration
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        progressLayer.add(animation, forKey: "line")
        CATransaction.commit()
    }
    
    private func drawPassedSegments(activeSegment: Int) {
        guard activeSegment > 0 else {
            return
        }
        for index in 0..<activeSegment {
            let layer = segments[index]
            layer.strokeEnd = 1.0
        }
    }
    
    private func drawSegmentToFull(index: Int, completion: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
           completion()
        }
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 1.0
        animation.duration = settings.animationDuration / 2
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        segments[index].add(animation, forKey: "line")
        CATransaction.commit()
    }
    
    func updateProgress(percent: Degrees) {
        var validatedPercent = percent / 100
        if percent > 100 {
            validatedPercent = 1
        }
        let singlePart = 1 / Degrees(settings.segmentsCount)
        let activeSegment = Int(floor(validatedPercent / singlePart))
        drawPassedSegments(activeSegment: activeSegment)
        let newValueOnActiveSegment = (validatedPercent - singlePart * Degrees(activeSegment)) * Degrees(settings.segmentsCount)
        guard activeSegment < settings.segmentsCount else {
            updateProgressInLayer(progressLayer: segments[activeSegment - 1],
                                  percent: Radians(validatedPercent),
                                  segmentIndex: activeSegment - 1)
            return
        }
        if self.activeSegment != activeSegment {
            drawSegmentToFull(index: self.activeSegment, completion: {
                self.value = 0.0
                self.updateProgressInLayer(progressLayer: self.segments[activeSegment],
                                           percent: Radians(newValueOnActiveSegment),
                                           segmentIndex: activeSegment)
            })
        } else {
            updateProgressInLayer(progressLayer: segments[activeSegment],
                                  percent: Radians(newValueOnActiveSegment),
                                  segmentIndex: activeSegment)
        }
        
    }
    
}
