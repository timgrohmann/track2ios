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

    var stations: [Station] = []
    var selectedCallback: ((Station?) -> Void)

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

    init(selectedCallback: @escaping (Station?) -> Void) {
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

    func finishedWithResult(_ stat: Station?) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        searchTextField.resignFirstResponder()
        selectedCallback(stat)
    }

    // MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reusedCell = tableView.dequeueReusableCell(withIdentifier: "st")
        if reusedCell == nil {
            reusedCell = UINib(nibName: "StationTableViewCell", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? StationTableViewCell
        }
        guard let cell = reusedCell as? StationTableViewCell else {
            fatalError("Could not create new cell")
        }
        let ind = indexPath.last!
        cell.display(station: stations[ind])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        finishedWithResult(stations[indexPath.last!])
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return stations[indexPath.row].code == ""
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let toBeDeleted = stations[indexPath.row]
            stations.remove(at: indexPath.row)
            dataController.delete(toBeDeleted)
            dataController.save()
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)

        }
    }

    // MARK: - Text field

    @IBAction func searchValueChanged(_ sender: Any) {
        let searchString = searchTextField.text ?? ""
        if searchString.count >= 1 {
            /*dataController.api.getLocations(name: s) {
                stat, error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.stations = stat
                        self.stationsTableView.reloadData()
                    }
                }
            }*/
            stations = dataController.searchStations(search: searchString)
            self.stationsTableView.reloadData()
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
            let newStation = dataController.makeStation()
            newStation.name = manualName
            newStation.code = ""
            dataController.save()
            finishedWithResult(newStation)
            return true
        }
        return false
    }

}
