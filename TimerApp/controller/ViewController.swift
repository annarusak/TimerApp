//
//  ViewController.swift
//  TimerApp
//
//  Created by Анна on 28.10.23.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let roundButtonSize : CGFloat = 90
    private let startButtonColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.3)
    private let pauseButtonColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 0.4)
    private let unenabledLapButtonColor = UIColor(red: 171/255, green: 171/255, blue: 171/255, alpha: 0.2)
    private let lapResetButtonColor = UIColor(red: 171/255, green: 171/255, blue: 171/255, alpha: 0.4)
    private let buttonDefaultAlpha = 0.7
    private let fractionTimer = FractionTimer()
    var lapTableView = UITableView()
    let identifier = "lapCell"
    var lapTimerTimestamps: [String] = []
    var lastLapsTimeString: [String] = []
    var lapTimes: [Int] = []
    var statusOfValue = foundMaxMinValue.middleValue
    
    enum foundMaxMinValue {
        case maxValue
        case minValue
        case middleValue
    }

    var lapCount = 0 {
        didSet {
            if (lapCount == 0) {
                lapTimerTimestamps.removeAll()
            } else {
                lapTimestampsUpdate()
            }
            lapTableView.reloadData()
        }
    }
    
    var startPauseButtonState = StartPauseButtonState.start {
        didSet {
            if (startPauseButtonState == .stop) {
                fractionTimer.start()
            } else {
                fractionTimer.stop()
            }
        }
    }
    var lapResetButtonState = LapResetButtonState.unenabledLap
    
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00,00"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: 75, weight: UIFont.Weight.thin)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var lapResetButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Lap", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.tintColor = .white
        button.backgroundColor = unenabledLapButtonColor
        button.alpha = buttonDefaultAlpha
        button.layer.cornerRadius = roundButtonSize / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(lapResetButtonTapped(sender:)), for: .touchUpInside)
        button.changeAlphaWhenHighlighted()
        return button
    }()
    
    private lazy var startPauseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22)
        button.setTitleColor(.green, for: .normal)
        button.backgroundColor = startButtonColor
        button.alpha = buttonDefaultAlpha
        button.layer.cornerRadius = roundButtonSize / 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startPauseButtonTapped(sender:)), for: .touchUpInside)
        button.changeAlphaWhenHighlighted()
        return button
    }()
 
    func createTable() {
        //      MARK: - по-другому сделать размерные привязки таблицы
        lapTableView = UITableView(frame: view.bounds.offsetBy(dx: 0, dy: 550), style: .plain)
        lapTableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        lapTableView.delegate = self
        lapTableView.dataSource = self
        lapTableView.separatorStyle = .singleLine
        lapTableView.separatorInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        lapTableView.separatorColor = .white
        lapTableView.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fractionTimer.addDelegate(delegate: timerDelegate)
        createTable()
        setupViews()
    }
    
    func setupViews() {
        view.backgroundColor = .black
        view.addSubview(lapResetButton)
        view.addSubview(startPauseButton)
        view.addSubview(timerLabel)
        view.addSubview(lapTableView)
        NSLayoutConstraint.activate([
            lapResetButton.topAnchor.constraint(equalTo: view.centerYAnchor),
            lapResetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            lapResetButton.widthAnchor.constraint(equalToConstant: roundButtonSize),
            lapResetButton.heightAnchor.constraint(equalToConstant: roundButtonSize),
            startPauseButton.topAnchor.constraint(equalTo: view.centerYAnchor),
            startPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: +100),
            startPauseButton.widthAnchor.constraint(equalToConstant: roundButtonSize),
            startPauseButton.heightAnchor.constraint(equalToConstant: roundButtonSize),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -100)
        ])
    }
    
    func setupStartPauseButton(button: UIButton) {
        switch startPauseButtonState {
        case .start:
            button.setTitle(startPauseButtonState.rawValue, for: .normal)
            button.setTitleColor(.green, for: .normal)
            button.backgroundColor = startButtonColor
        case .stop:
            button.setTitle(startPauseButtonState.rawValue, for: .normal)
            button.setTitleColor(.red, for: .normal)
            button.backgroundColor = pauseButtonColor
        }
    }
    
    func setupLapResetButton(button: UIButton) {
        switch lapResetButtonState {
        case .unenabledLap:
            button.setTitle("Lap", for: .normal)
            button.setTitleColor(.lightGray, for: .normal)
            button.backgroundColor = unenabledLapButtonColor
        case .lap:
            button.setTitle(lapResetButtonState.rawValue, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = lapResetButtonColor
        case .reset:
            button.setTitle(lapResetButtonState.rawValue, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = lapResetButtonColor
        }
    }
    
    @objc func lapResetButtonTapped(sender: UIButton) {
        switch lapResetButtonState {
        case .reset:
            setupAfterResetButton()
        case .unenabledLap:
            return
        case .lap:
            lapCount += 1
        }
        setupLapResetButton(button: lapResetButton)
    }
    
    @objc func startPauseButtonTapped(sender: UIButton) {
        startPauseButtonState = startPauseButtonState == .start ? .stop : .start
        setupStartPauseButton(button: startPauseButton)
        lapResetButtonState = (startPauseButtonState == .stop) ? .lap : .reset
        setupLapResetButton(button: lapResetButton)
    }
    
    private func setupAfterResetButton() {
        timerLabel.text = "00:00,00"
        fractionTimer.reset()
        lapResetButtonState = .unenabledLap
        lapCount = 0
        lastLapsTimeString.removeAll()
        lapTimes.removeAll()
        lapTableView.reloadData()
        
    }

    private func lapTimestampsUpdate() {
        if let timeMeasure = timerLabel.text {
            lapTimerTimestamps.append(timeMeasure)
            calculateLapTime()
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
    
    private func calculateLapTime() {
        if lapCount == 1 {
            print(lapTimerTimestamps[0])
            lastLapsTimeString.append(lapTimerTimestamps[0])
            let firstLapTime = Int(lapTimerTimestamps[0].replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)) ?? 0
            lapTimes.append(firstLapTime)
        } else {
            let countOfArray = lapTimerTimestamps.count
            let strTimestampLastLap = lapTimerTimestamps[countOfArray - 1]
            let strTimestampPreLastLap = lapTimerTimestamps[countOfArray - 2]
            print(strTimestampLastLap)
            print(strTimestampPreLastLap)

            let timestampLastLap = Int(strTimestampLastLap.replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)) ?? 0
            let timestampPreLastLap = Int(strTimestampPreLastLap.replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)) ?? 0

            let lapTime = timestampLastLap - timestampPreLastLap
            lapTimes.append(lapTime)
            print(lapTime)

            let lapTimeString = formatTime(timerPeriod: lapTime)

            lastLapsTimeString.insert(lapTimeString, at: 0)
        }
    }
    
    func timerDelegate(tuple : (minutes: Int, seconds: Int, fractions: Int)) {
        timerLabel.text = "\(String(format: "%02d", tuple.minutes)):\(String(format: "%02d", tuple.seconds)),\(String(format: "%02d", tuple.fractions))"
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapCount
    }
    
    //      MARK: - dequeueReusableCell?
    //        tableView.dequeueReusableCell(withIdentifier: "lapCell", for: indexPath)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "lapCell")
        cell.backgroundColor = .black
        
        //      MARK: - Depricated figure out
        //        var content = cell.defaultContentConfiguration()
        //        content.text = number
        //        content.secondaryText = number
        //        cell.contentConfiguration = content
        
        let lapTableNumber = lapCount - indexPath.row
        let lastLapTimeString = lastLapsTimeString[indexPath.row]
        cell.textLabel?.text = "Lap " + String(lapTableNumber)
        if lapCount < 3 {
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
            cell.detailTextLabel?.text = String(lastLapTimeString)
        } else {
            let maxMeasureValue = lapTimes.max()
            let minMeasureValue = lapTimes.min()
            let strMaxMeasureValue = String(maxMeasureValue!)
            let strMinMeasureValue = String(minMeasureValue!)

            let cellText = lastLapTimeString

            cell.detailTextLabel?.text = cellText
            let cellTextWithoutPunktMarks = cellText.replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)

            if cellTextWithoutPunktMarks.contains(strMaxMeasureValue) {
                cell.detailTextLabel?.textColor = .red
                cell.textLabel?.textColor = .red
            }
            else if cellTextWithoutPunktMarks.contains(strMinMeasureValue) {
                cell.detailTextLabel?.textColor = .green
                cell.textLabel?.textColor = .green
            }
            else {
                cell.detailTextLabel?.textColor = .white
                cell.textLabel?.textColor = .white
            }
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    
    
}

