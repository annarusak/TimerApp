import Foundation

class FractionTimer {
    
    private var startTime: Date?
    private var sceduledTimer: Timer!
    private var delegate: (((Int, Int, Int)) -> Void)?
    var (minutes, seconds, fractions) = (0, 0, 0)
    
    /// A method that increments the timer and notifies the delegate.
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
    
    /// Starts the timer.
    public func start() {
        startTime = Date()
        sceduledTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(FractionTimer.keepTimer), userInfo: nil, repeats: true)
    }
    
    /// Stops the timer.
    func stop() {
        if sceduledTimer != nil {
            sceduledTimer.invalidate()
        }
    }
    
    /// Resets the timer to zero.
    func reset() {
        (minutes, seconds, fractions) = (0, 0, 0)
    }
    
    /**
     Adds a delegate to receive timer updates.
     - Parameter delegate: A closure to be called with timer updates.
     */
    func addDelegate(delegate: @escaping ((Int, Int, Int)) -> Void) {
        self.delegate = delegate
    }
}
