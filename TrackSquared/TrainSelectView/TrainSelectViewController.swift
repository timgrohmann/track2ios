//
//  TrainSelectViewController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 14.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class TrainSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var descriptorLabel: UILabel!
    @IBOutlet weak var buttonBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var trainTableView: UITableView!

    let selectedCallback: (Train?, Date?) -> Void
    let station: DBAPI.APIStation?

    var departures: [TimetablesAPI.Stop] = []
    var selectedStop: TimetablesAPI.Stop?

    var tableFadeOutLayer: CAGradientLayer?

    var hourOffset: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Zug auswählen"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Abbrechen", style: .done, target: self.navigationController, action: #selector(UINavigationController.popToRootViewController(animated:)))

        indicateInvalidity()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        loadDeparturesForStation()

    }

    override func viewDidLayoutSubviews() {
        //addMaskLayerToTableView()
    }

    init(station: DBAPI.APIStation?, selectedCallback: @escaping (Train?, Date?) -> Void) {
        self.selectedCallback = selectedCallback
        self.station = station
        super.init(nibName: "TrainSelectViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.selectedCallback = {_, _  in}
        self.station = nil
        super.init(coder: aDecoder)
    }

    @IBAction func inputTextFieldChanged(_ sender: UITextField) {
        guard let text = sender.text else {return}

        processNewTrain(trainName: text)
    }

    func processNewTrain(trainName: String) {
        let parts = makeParts(text: trainName)

        if let trainName = parts {
            descriptorLabel.text = String(format: "%@ %@", trainName.type, trainName.number)
            descriptorLabel.textColor = UIColor.black
        } else {
            indicateInvalidity()
        }
    }

    func isValid(text: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: "^([A-Z]+) {0,1}([0-9]+)$") else { return true }
        let result = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        return result.count == 1
    }

    func makeParts(text: String) -> Train.NameDesriptor? {
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: "^([A-Z]+) {0,1}([0-9]+)$")

        let startIndex = text.startIndex
        let result = regex.matches(in: text, range: NSRange(startIndex..., in: text))

        if result.count == 1 {
            let match = result[0]
            let typeRange = match.range(at: 1)
            let typeStart = text.index(startIndex, offsetBy: typeRange.location)
            let typeEnd = text.index(startIndex, offsetBy: typeRange.location + typeRange.length)
            let type = text[typeStart..<typeEnd]

            let numberRange = match.range(at: 2)
            let numberStart = text.index(startIndex, offsetBy: numberRange.location)
            let numberEnd = text.index(startIndex, offsetBy: numberRange.location + numberRange.length)
            let number = text[numberStart..<numberEnd]
            return Train.NameDesriptor(type: String(type), number: String(number))
        } else {
            return nil
        }

    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            buttonBottomLayoutConstraint.constant = keyboardHeight
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func indicateInvalidity() {
        descriptorLabel.text = "Nicht gültig!"
        descriptorLabel.textColor = UIColor.red
    }

    func finishedWithResult(_ stat: Train?, date: Date?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        searchTextField.resignFirstResponder()
        selectedCallback(stat, date)
    }

    @IBAction func laterButtonPresse(_ sender: Any) {
        hourOffset += 1
        loadDeparturesForStation()
    }

    @IBAction func earlierButtonPressed(_ sender: Any) {
        hourOffset -= 1
        loadDeparturesForStation()
    }

    func loadDeparturesForStation() {
        guard let station = station else {
            return
        }

        /*dataController.timetablesAPI.getPlan(evaNo: String(station.id), date: Date().addingTimeInterval(60.0 * 60.0 * Double(hourOffset))) { result in
            switch result {
            case .success(let stops):
                self.departures = stops.filter { $0.departure != nil }
            case .failure:
                self.departures = []
            }

            DispatchQueue.main.async {
                self.trainTableView.reloadData()
            }
        }*/

        dataController.tt.getRealTimeDepartures(for: String(station.id), offset: hourOffset) { departures in
            self.departures = departures
            self.trainTableView.reloadData()
        }
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departures.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reusedCell = trainTableView.dequeueReusableCell(withIdentifier: "train")
        if reusedCell == nil {
            reusedCell = UINib(nibName: "TrainSelectTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TrainSelectTableViewCell
        }
        guard let cell = reusedCell as? TrainSelectTableViewCell else {
            fatalError("Could not create new cell")
        }
        cell.displayDeparture(departures[indexPath.row], at: station)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedStop = departures[indexPath.row]
        if let trainName = selectedStop?.train.getDisplayName(),
            let nameDesc = makeParts(text: trainName) {
            let traintype = Train.typeMap[nameDesc.type.uppercased()] ?? .NE
            let train = dataController.getTrain(number: nameDesc.number, trainType: traintype) ?? dataController.makeTrain()

            train.number = nameDesc.number
            train.type = traintype
            dataController.save()
            finishedWithResult(train, date: selectedStop?.departure!.timestamp)
        }
    }

    func addMaskLayerToTableView() {
        if tableFadeOutLayer != nil {
            return
        }

        tableFadeOutLayer = CAGradientLayer()

        let transparent = UIColor(white: 1.0, alpha: 0.0).cgColor
        let white = UIColor.systemBackground.cgColor

        let space = 0.02

        tableFadeOutLayer?.colors = [white, transparent, transparent, white]
        tableFadeOutLayer?.locations = [0.0, NSNumber(value: space), NSNumber(value: 1.0 - space), 1.0]
        tableFadeOutLayer?.position = trainTableView.frame.origin
        tableFadeOutLayer?.bounds = CGRect(x: 0.0, y: 0.0, width: trainTableView.frame.width, height: trainTableView.frame.height)
        tableFadeOutLayer?.anchorPoint = .zero
        tableFadeOutLayer?.name = "Table transparency"

        view.layer.addSublayer(tableFadeOutLayer!)
    }

    // MARK: - Text Field

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField != searchTextField { return true }

        if let nameDesc = makeParts(text: searchTextField.text ?? "") {
            let traintype = Train.typeMap[nameDesc.type.uppercased()] ?? .NE
            let train = dataController.getTrain(number: nameDesc.number, trainType: traintype) ?? dataController.makeTrain()

            train.number = nameDesc.number
            train.type = traintype

            finishedWithResult(train, date: selectedStop?.departure!.timestamp)
            return true
        } else {
            return false
        }
    }
}
