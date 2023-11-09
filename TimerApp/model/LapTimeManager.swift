import Foundation

/// A class managing lap times and lap-related calculations.
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
    
    /**
     Adds a lap timestamp and calculates lap time.
     - Parameter timestamp: The timestamp of the lap.
     */
    func addLap(timestamp: String) {
        lapCount += 1
        lapTimerTimestamps.append(timestamp)
        calculateLapTime()
    }
    
    /**
     Retrieves the current lap count.
     - Returns: The current lap count.
     */
    func getLapCount() -> Int {
        return lapCount
    }
    
    /// Resets lap-related data.
    func reset() {
        lapCount = 0
        lastLapsTimeString.removeAll()
        lapTimes.removeAll()
    }
    
    /**
     Retrieves the lap time for a specific lap.
     - Parameter lap: The lap number.
     - Returns: The lap time as a formatted string.
     */
    func getLastLapTime(lap: Int) -> String? {
        return lastLapsTimeString[lap]
    }
    
    /**
     Retrieves the minimum lap time.
     - Returns: The minimum lap time as an integer.
     */
    func lapMin() -> Int? {
        return lapTimes.min()
    }
    
    /**
     Retrieves the maximum lap time.
     - Returns: The maximum lap time as an integer.
     */
    func lapMax() -> Int? {
        return lapTimes.max()
    }
    
    /**
     Retrieves the minimum lap time as a formatted string.
     - Returns: The minimum lap time as a formatted string.
    */
    func lapMin() -> String {
        if let lapMin = lapTimes.min() {
            return String(lapMin)
        } else {
            return ""
        }
    }
    
    /**
     Retrieves the maximum lap time as a formatted string.
     - Returns: The maximum lap time as a formatted string.
     */
    func lapMax() -> String {
        if let lapMax = lapTimes.max() {
            return String(lapMax)
        } else {
            return ""
        }
    }
    
    /// Calculates the lap time based on the recorded lap timestamps.
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
    
    /**
     Formats a time period (in centiseconds) into a string representation (mm:ss,SS).
     - Parameter timerPeriod: The time period in centiseconds.
     - Returns: The formatted time string.
    */
    private func formatTime(timerPeriod: Int) -> String {
        let minutes = timerPeriod / 6000  /// Calculate minutes (60 seconds * 100 centiseconds)
        let seconds = (timerPeriod / 100) % 60  /// Calculate remaining seconds
        let centiseconds = timerPeriod % 100  /// Calculate remaining centiseconds
        /// Create the formatted string
        let formattedTime = String(format: "%02d:%02d,%02d", minutes, seconds, centiseconds)
        return formattedTime
    }
    
}
