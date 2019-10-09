//
//  StationSelectViewController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 12.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class StationSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stationsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    
    var stations: [DBAPI.APIStation] = []
    var selectedCallback: ((DBAPI.APIStation?) -> ())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Used to get keyboard size to adjust bottom table offset
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        searchTextField.becomeFirstResponder()
    }
    
    init(selectedCallback: @escaping (DBAPI.APIStation?) -> ()) {
        self.selectedCallback = selectedCallback
        super.init(nibName: "StationSelectView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.selectedCallback = {_ in}
        super.init(coder: aDecoder)
    }

    @IBAction func abortButtonPressed(_ sender: Any) {
        finishedWithResult(nil)
    }
    
    func finishedWithResult(_ stat: DBAPI.APIStation?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        searchTextField.resignFirstResponder()
        selectedCallback(stat)
    }
    
    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCell(withIdentifier: "st")
        if c == nil {
            c = UINib(nibName: "StationTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! StationTableViewCell
        }
        guard let cell = c as? StationTableViewCell else {
            fatalError("Could not create new cell")
        }
        let ind = indexPath.last!
        cell.display(station: stations[ind])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        finishedWithResult(stations[indexPath.last!])
    }

    // MARK: - Text field
    
    @IBAction func searchValueChanged(_ sender: Any) {
        let s = searchTextField.text ?? ""
        if s.count >= 3{
            dataController.api.getLocations(name: s) {
                stat, error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.stations = stat
                        self.stationsTableView.reloadData()
                    }
                }
            }
        } else {
            stations = []
            stationsTableView.reloadData()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            tableViewBottomConstraint.constant = keyboardHeight
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let manualName = searchTextField.text, manualName.count >= 3 {
            finishedWithResult(DBAPI.APIStation(name: manualName, id: -1))
            return true
        }
        return false
    }
    
}
