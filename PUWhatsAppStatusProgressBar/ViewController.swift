//
//  ViewController.swift
//  PUWhatsAppStatusProgressBar
//
//  Created by ABHI on 09/01/24.
//

import UIKit

class ViewController: UIViewController {
 
    @IBOutlet weak var vwProgress: UIView!
    var indicators: [PUWAppStatusProgressIndicator] = []
    override func viewDidLoad() {
        super.viewDidLoad()
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setupADStausProgressBar()
           
            var progressInPercents = 1.0
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                progressInPercents = progressInPercents + 2.0
                self.indicators.forEach {
                    $0.updateProgress(percent: progressInPercents)
                }
                if progressInPercents > 100.0
                {
                    timer.invalidate()
                }
            }
        }
        
            self.setupCircleIndicator()
        
    }
}

extension ViewController
{
   
    func setupADStausProgressBar() {
        var settings = PUWAppStatusProgressIndicatorSettings()
        settings.isStaticSegmentsVisible = true
        settings.startPointPadding = -90
        settings.defaultSegmentColor = UIColor.darkGray
        settings.segmentColor = UIColor.blue
        settings.targetSegmentColor = UIColor.yellow
        settings.targetSegementNumber = 12 // total 13 DAYS TARGET allocated so value = total - 1
        settings.segmentBorderType = .round
        settings.segmentsCount = Date().getDaysInMonth()
        settings.colorSegementCount = 12 // your actual days count here
        settings.spaceBetweenSegments = 2
        settings.segmentWidth = 3
        let segment = PUWAppStatusProgressIndicator(frame: CGRect(x: 40, y: 100, width: 150.0, height: 150.0))
        segment.settings = settings
        indicators.append(segment)
        self.vwProgress.addSubview(segment)
    }
    
    func setupCircleIndicator() {
        var settings = PUCircularSliderSettings()
        settings.minimumValue = 0
        settings.maximumValue = 1000
        settings.lineWidth = 5
        settings.puNormalColor = UIColor.yellow
        settings.puHighlightedColor = UIColor.blue
        settings.isPlainColor = false
        settings.gradientColors = [UIColor.red,UIColor.blue,UIColor.white]
        settings.highlighted = true
        settings.ringColor = .black
        settings.circleFillColor = .clear
        let segment = PUCircularSlider(frame: CGRect(x: 40, y: 300, width: 200.0, height: 200.0))
        segment.settings = settings
        self.vwProgress.addSubview(segment)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            segment.setValue(160, animated: true)
        }
    }
}

