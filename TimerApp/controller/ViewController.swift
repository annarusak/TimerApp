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
    var myTableView = UITableView()
    let identifier = "lapCell"
    let array = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    var startPauseButtonState = StartPauseButtonState.start
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fractionTimer.addDelegate(delegate: timerDelegate)
        createTable()
        setupViews()
    }
    
    func createTable() {
//      MARK: - по-другому сделать размерные привязки таблицы
        self.myTableView = UITableView(frame: view.bounds.offsetBy(dx: 0, dy: 550), style: .plain)
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        view.addSubview(myTableView)
    }
    
    func setupViews() {
        view.backgroundColor = .black
        view.addSubview(lapResetButton)
        view.addSubview(startPauseButton)
        view.addSubview(timerLabel)
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
//            myTableView.topAnchor.constraint(equalTo: startPauseButton.bottomAnchor, constant: -200)
        ])
    }
    
    @objc func lapResetButtonTapped(sender: UIButton) {
        switch lapResetButtonState {
        case .reset:
            timerLabel.text = "00:00,00"
            fractionTimer.reset()
            lapResetButtonState = .unenabledLap
            break
        case .unenabledLap:
            return
        case .lap:
            timeMeasure()
            break
        }
        setupLapResetButton(button: lapResetButton)
    }
    
    @objc func startPauseButtonTapped(sender: UIButton) {
        if startPauseButtonState == .start {
            fractionTimer.start()
        } else {
            fractionTimer.stop()
        }
        startPauseButtonState = startPauseButtonState == .start ? .stop : .start
        setupStartPauseButton(button: startPauseButton)
        lapResetButtonState = (startPauseButtonState == .stop) ? .lap : .reset
        setupLapResetButton(button: lapResetButton)
    }
    
    private func timeMeasure() {
        // TODO
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
    
    func timerDelegate(tuple : (minutes: Int, seconds: Int, fractions: Int)) {
        timerLabel.text = "\(String(format: "%02d", tuple.minutes)):\(String(format: "%02d", tuple.seconds)),\(String(format: "%02d", tuple.fractions))"
    }
    
    
    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    //      MARK: - Как сделать dequeueReusableCell?
    //        tableView.dequeueReusableCell(withIdentifier: "lapCell", for: indexPath)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        tableView.separatorColor = .white
        tableView.backgroundColor = .black
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "lapCell")
        let number = array[indexPath.row]
        
//      MARK: - Деприкейтед - исправить
        //        var content = cell.defaultContentConfiguration()
        //        content.text = number
        //        content.secondaryText = number
        //        cell.contentConfiguration = content
        cell.backgroundColor = .black
        cell.textLabel?.text = number
        cell.detailTextLabel?.text = "1"
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    
    
}

