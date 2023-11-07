import Foundation

class LapTimeManager {
    
    private var lapTimerTimestamps: [String] = []
    private var lastLapsTimeString: [String] = []
    private var lapTimes: [Int] = []
    
    private var lapCount = 0 {
        didSet {
            if (lapCount == 0) {
                lapTimerTimestamps.removeAll()
            }
        }
    }
    
    func addLap(timestamp: String) {
        lapCount+=1
        lapTimerTimestamps.append(timestamp)
        calculateLapTime()
    }
    
    func getLapCount() -> Int {
        return lapCount
    }
    
    func reset() {
        lapCount = 0
        lastLapsTimeString.removeAll()
        lapTimes.removeAll()
    }
    
    func getLastLapTime(lap: Int) -> String? {
        return lastLapsTimeString[lap]
    }
    
    func lapMin() -> Int? {
        return lapTimes.min()
    }
    
    func lapMax() -> Int? {
        return lapTimes.max()
    }
    
    func lapMin() -> String {
        if let lapMin = lapTimes.min() {
            return String(lapMin)
        } else {
            return ""
        }
    }
    
    func lapMax() -> String {
        if let lapMax = lapTimes.max() {
            return String(lapMax)
        } else {
            return ""
        }
    }
    
    private func calculateLapTime() {
        if lapCount == 1 {
            lastLapsTimeString.append(lapTimerTimestamps[0])
            let firstLapTime = Int(lapTimerTimestamps[0].replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)) ?? 0
            lapTimes.append(firstLapTime)
        } else {
            let countOfArray = lapTimerTimestamps.count
            let strTimestampLastLap = lapTimerTimestamps[countOfArray - 1]
            let strTimestampPreLastLap = lapTimerTimestamps[countOfArray - 2]

            let timestampLastLap = Int(strTimestampLastLap.replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)) ?? 0
            let timestampPreLastLap = Int(strTimestampPreLastLap.replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)) ?? 0

            let lapTime = timestampLastLap - timestampPreLastLap
            lapTimes.append(lapTime)

            let lapTimeString = formatTime(timerPeriod: lapTime)

            lastLapsTimeString.insert(lapTimeString, at: 0)
        }
    }
    
    private func formatTime(timerPeriod: Int) -> String {
        let minutes = timerPeriod / 6000  // Calculate minutes (60 seconds * 100 centiseconds)
        let seconds = (timerPeriod / 100) % 60  // Calculate remaining seconds
        let centiseconds = timerPeriod % 100  // Calculate remaining centiseconds
        // Create the formatted string
        let formattedTime = String(format: "%02d:%02d,%02d", minutes, seconds, centiseconds)
        
        return formattedTime
    }
    
}
