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
        settings.targetSegementNumber = 12 // total 13 Activedays allocated so value = total - 1
        settings.segmentBorderType = .round
        settings.segmentsCount = Date().getDaysInMonth()
        settings.colorSegementCount = 11 // TOTAL ACTIVE DAYS COUNT SET HERE
        settings.spaceBetweenSegments = 1
        settings.segmentWidth = 4
        let segment = PUWAppStatusProgressIndicator(frame: CGRect(x: 40, y: 100, width: 150.0, height: 150.0))
        segment.settings = settings
        indicators.append(segment)
        self.vwProgress.addSubview(segment)
    }
}
