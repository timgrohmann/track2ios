//
//  TrainSelectViewController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 14.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class TrainSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var descriptorLabel: UILabel!
    @IBOutlet weak var buttonBottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var trainTableView: UITableView!
    
    let selectedCallback: (Train?, Date?) -> ()
    let station: DBAPI.APIStation?

    var trains: [DBAPI.APITrain] = []
    var selectedTrain: DBAPI.APITrain?
    
    var tableFadeOutLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        addMaskLayerToTableView()
    }

    init(station: DBAPI.APIStation?, selectedCallback: @escaping (Train?, Date?) -> ()) {
        self.selectedCallback = selectedCallback
        self.station = station
        super.init(nibName: "TrainSelectViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.selectedCallback = {_,_  in}
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
            chooseButton.isEnabled = true
        } else {
            indicateInvalidity()
        }
    }
    
    func isValid(text: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^([A-Z]+) {0,1}([0-9]+)$")
        let result = regex.matches(in:text, range: NSRange(text.startIndex..., in: text))
        return result.count == 1
    }
    
    func makeParts(text: String) -> Train.NameDesriptor? {
        let regex = try! NSRegularExpression(pattern: "^([A-Z]+) {0,1}([0-9]+)$")
        
        let startIndex = text.startIndex
        let result = regex.matches(in:text, range: NSRange(startIndex..., in: text))
        
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
        chooseButton.isEnabled = false
    }
    
    func finishedWithResult(_ stat: Train?, date: Date?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        searchTextField.resignFirstResponder()
        selectedCallback(stat, date)
    }
    
    @IBAction func abortButtonPressed(_ sender: Any) {
        finishedWithResult(nil, date: nil)
    }
    
    @IBAction func chooseButtonPressed(_ sender: Any) {
        if let nameDesc = makeParts(text: searchTextField.text ?? "") {
            let traintype = Train.typeMap[nameDesc.type.uppercased()] ?? .NE
            let train = dataController.getTrain(number: nameDesc.number, trainType: traintype) ?? dataController.makeTrain()
            
            train.number = nameDesc.number
            train.type = traintype
            
            // Retrieves time from currently selected real train if there is one
            let dateParser = DateFormatter()
            dateParser.dateFormat = "HH:mm"
            
            let stop = selectedTrain?.stops.first {$0.stopId == station?.id}
            guard let departureTime = dateParser.date(from: stop?.depTime ?? "") else {
                finishedWithResult(train, date: nil)
                return
            }
            
            let timeComponents = Calendar.current.dateComponents(in: .current, from: departureTime)
            
            // Sets time to current date
            var components = Calendar.current.dateComponents(in: .current, from: Date())
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            components.second = 0
            
            finishedWithResult(train, date: Calendar.current.date(from: components))
        }
    }
    
    func loadDeparturesForStation() {
        guard let station = station else {
            return
        }
        
        var departingTrains: [DBAPI.APITrain] = []
                
        // Get departures from at most 20 minutes ago
        dataController.api.getDepartures(station: station, time: Date().addingTimeInterval(-60*20)) {
            departures, error in
            let trainDispatch = DispatchGroup()
            for dep in departures {
                trainDispatch.enter()
                DispatchQueue.main.async {
                    dataController.api.getTrainStopDetails(departure: dep) {
                        details, error in
                        departingTrains.append(DBAPI.APITrain(stops: details))
                        trainDispatch.leave()
                    }
                }
            }
            trainDispatch.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.trains = departingTrains
                    self.trainTableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trains.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var c = trainTableView.dequeueReusableCell(withIdentifier: "train")
        if c == nil {
            c = UINib(nibName: "TrainSelectTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TrainSelectTableViewCell
        }
        guard let cell = c as? TrainSelectTableViewCell else {
            fatalError("Could not create new cell")
        }
        cell.displayTrain(train: trains[indexPath.row], at: station)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrain = trains[indexPath.row]
        guard let selectedTrainName = selectedTrain?.name else {return}
        searchTextField.text = selectedTrainName
        processNewTrain(trainName: selectedTrainName)
    }
    
    func addMaskLayerToTableView() {
        if tableFadeOutLayer != nil {
            return
        }
        
        tableFadeOutLayer = CAGradientLayer()
        
        let transparent = UIColor(white: 1.0, alpha: 0.0).cgColor
        let white = UIColor(white: 1.0, alpha: 1.0).cgColor
        
        let space = 0.02
        
        tableFadeOutLayer?.colors = [white,transparent,transparent,white]
        tableFadeOutLayer?.locations = [0.0, NSNumber(value: space), NSNumber(value: 1.0 - space), 1.0]
        tableFadeOutLayer?.position = trainTableView.frame.origin
        tableFadeOutLayer?.bounds = CGRect(x: 0.0, y: 0.0, width: trainTableView.frame.width, height: trainTableView.frame.height)
        tableFadeOutLayer?.anchorPoint = .zero
        tableFadeOutLayer?.name = "Table transparency"
        
        view.layer.addSublayer(tableFadeOutLayer!)
    }
}
