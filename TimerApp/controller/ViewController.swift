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
    private var lapTableView = UITableView()
    private let identifier = "lapCell"
    private let lapTimeManger = LapTimeManager()
    
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
            lapTimestampsUpdate()
            lapTableView.reloadData()
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
        lapTimeManger.reset()
        lapTableView.reloadData()
        
    }

    private func lapTimestampsUpdate() {
        if let timeMeasure = timerLabel.text {
            lapTimeManger.addLap(timestamp: timeMeasure)
        }
    }

    func timerDelegate(tuple : (minutes: Int, seconds: Int, fractions: Int)) {
        timerLabel.text = "\(String(format: "%02d", tuple.minutes)):\(String(format: "%02d", tuple.seconds)),\(String(format: "%02d", tuple.fractions))"
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimeManger.getLapCount()
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
        
        let lapCount = lapTimeManger.getLapCount()
        let lapTableNumber = lapCount - indexPath.row
        let lastLapTimeString = lapTimeManger.getLastLapTime(lap: indexPath.row) ?? ""
        cell.textLabel?.text = "Lap " + String(lapTableNumber)

        if lapCount < 3 {
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white
            cell.detailTextLabel?.text = String(lastLapTimeString)
        } else {
            let cellText = lastLapTimeString
            cell.detailTextLabel?.text = cellText
            let cellTextWithoutPunktMarks = cellText.replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)

            if cellTextWithoutPunktMarks.contains(lapTimeManger.lapMax()) {
                cell.detailTextLabel?.textColor = .red
                cell.textLabel?.textColor = .red
            } else if cellTextWithoutPunktMarks.contains(lapTimeManger.lapMin()) {
                cell.detailTextLabel?.textColor = .green
                cell.textLabel?.textColor = .green
            } else {
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

