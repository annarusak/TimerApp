import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    // Constants for button size and colors
    private let roundButtonSize : CGFloat = 90
    private let startButtonColor = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 0.3)
    private let pauseButtonColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 0.4)
    private let unenabledLapButtonColor = UIColor(red: 171/255, green: 171/255, blue: 171/255, alpha: 0.2)
    private let lapResetButtonColor = UIColor(red: 171/255, green: 171/255, blue: 171/255, alpha: 0.4)
    private let buttonDefaultAlpha = 0.7
    
    // Timer and lap-related properties
    private let fractionTimer = FractionTimer()
    private var lapTableView = UITableView()
    private let identifier = "lapCell"
    private let lapTimeManger = LapTimeManager()
    
    // Button states
    private var startPauseButtonState = StartPauseButtonState.start {
        didSet {
            if (startPauseButtonState == .stop) {
                fractionTimer.start()
            } else {
                fractionTimer.stop()
            }
        }
    }
    private var lapResetButtonState = LapResetButtonState.unenabledLap
    
    // UI Elements
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
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fractionTimer.addDelegate(delegate: timerDelegate)
        createTable()
        setupViews()
    }
    
    // MARK: - UI Setup
    /// Configures the appearance and layout of UI components in the view.
    private func setupViews() {
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
            //
            startPauseButton.topAnchor.constraint(equalTo: view.centerYAnchor),
            startPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: +100),
            startPauseButton.widthAnchor.constraint(equalToConstant: roundButtonSize),
            startPauseButton.heightAnchor.constraint(equalToConstant: roundButtonSize),
            //
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            //
            lapTableView.topAnchor.constraint(equalTo: startPauseButton.bottomAnchor, constant: 20),
            lapTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            lapTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            lapTableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    /// Creates and configures the lap table view.
    private func createTable() {
        lapTableView = UITableView()
        lapTableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        lapTableView.delegate = self
        lapTableView.dataSource = self
        lapTableView.separatorStyle = .singleLine
        lapTableView.separatorInset = .init(top: 0, left: 10, bottom: 0, right: 10)
        lapTableView.separatorColor = .white
        lapTableView.backgroundColor = .black
        lapTableView.translatesAutoresizingMaskIntoConstraints = false
    }

    // MARK: - Button Setup
    /**
     Configures the appearance of the start/pause button based on its state.
     - Parameter button: The start/pause button to be configured.
     */
    private func setupStartPauseButton(button: UIButton) {
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
    
    /**
     Configures the appearance of the lap/reset button based on its state.
     - Parameter button: The lap/reset button to be configured.
     */
    private func setupLapResetButton(button: UIButton) {
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
    
    // MARK: - Button Actions
    /**
     Handles the tap event on the lap/reset button and performs corresponding actions.
     - Parameter sender: The lap/reset button that triggered the action.
     */
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
    
    /**
     Handles the tap event on the start/pause button and performs corresponding actions.
     - Parameter sender: The start/pause button that triggered the action.
     */
    @objc func startPauseButtonTapped(sender: UIButton) {
        startPauseButtonState = startPauseButtonState == .start ? .stop : .start
        setupStartPauseButton(button: startPauseButton)
        lapResetButtonState = (startPauseButtonState == .stop) ? .lap : .reset
        setupLapResetButton(button: lapResetButton)
    }
    
    /// Resets the timer and lap-related components to their initial state after a reset button press.
    private func setupAfterResetButton() {
        timerLabel.text = "00:00,00"
        fractionTimer.reset()
        lapResetButtonState = .unenabledLap
        lapTimeManger.reset()
        lapTableView.reloadData()
        
    }

    /// Updates lap timestamps and reloads the lap table view.
    private func lapTimestampsUpdate() {
        if let timeMeasure = timerLabel.text {
            lapTimeManger.addLap(timestamp: timeMeasure)
        }
    }

    // MARK: - Timer Delegate
    /**
     Updates the timer label based on the provided time components.
     - Parameter tuple: A tuple containing minutes, seconds, and fractions.
     */
    private func timerDelegate(tuple : (minutes: Int, seconds: Int, fractions: Int)) {
        timerLabel.text = "\(String(format: "%02d", tuple.minutes)):\(String(format: "%02d", tuple.seconds)),\(String(format: "%02d", tuple.fractions))"
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimeManger.getLapCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "lapCell")
        var content = cell.defaultContentConfiguration()
        cell.backgroundColor = .black
        let lapCount = lapTimeManger.getLapCount()
        let lapTableNumber = lapCount - indexPath.row
        let lastLapTimeString = lapTimeManger.getLastLapTime(lap: indexPath.row) ?? ""
        content.text = "Lap " + String(lapTableNumber)
        
        if lapCount < 3 {
            content.textProperties.color = .white
            content.secondaryTextProperties.color = .white
            content.secondaryText = String(lastLapTimeString)
        } else {
            content.secondaryText = lastLapTimeString
            let cellTextWithoutPunktMarks = lastLapTimeString.replacingOccurrences(of: "[:|,]", with: "", options: .regularExpression)
            
            if cellTextWithoutPunktMarks.contains(lapTimeManger.lapMax()) {
                content.secondaryTextProperties.color = .red
                content.textProperties.color = .red
            } else if cellTextWithoutPunktMarks.contains(lapTimeManger.lapMin()) {
                content.secondaryTextProperties.color = .green
                content.textProperties.color = .green
            } else {
                content.secondaryTextProperties.color = .white
                content.textProperties.color = .white
            }
        }
        cell.contentConfiguration = content
        return cell
    }

    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}

