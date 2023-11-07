import Foundation
import UIKit

class FractionTimer {
    
    private var startTime: Date?
    private var sceduledTimer: Timer!
    private var delegate: (((Int, Int, Int)) -> Void)?
    var (minutes, seconds, fractions) = (0, 0, 0)
 
    @objc func keepTimer() {
        if minutes < 100 {
            fractions += 1
            
            if fractions > 99 {
                seconds += 1
                fractions = 0
            }
            if seconds == 60 {
                minutes += 1
                seconds = 0
            }
            
            self.delegate?((minutes, seconds, fractions))
        } else {
            reset()
        }
    }
    
public
    func start() {
        startTime = Date()
        sceduledTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(FractionTimer.keepTimer), userInfo: nil, repeats: true)
    }
    
    func stop() {
        if sceduledTimer != nil {
            sceduledTimer.invalidate()
        }
    }
    
    func reset() {
        (minutes, seconds, fractions) = (0, 0, 0)
    }
    
    func addDelegate(delegate: @escaping ((Int, Int, Int)) -> Void) {
        self.delegate = delegate
    }
}
