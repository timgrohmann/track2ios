//
//  ViewController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 10.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var trainLabel: UILabel!
    @IBOutlet weak var sinceLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var devVersionLabel: UILabel!
    @IBOutlet weak var boardUnboardButton: ButtonDesignable!
    @IBOutlet weak var quitJourneyButton: ButtonDesignable!
    @IBOutlet weak var journeyTableView: UITableView!

    var timeTimer: Timer?
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataController.prepare()

        user = dataController.getUser()

        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let infoDict = NSDictionary(contentsOfFile: path),
            let version = infoDict["CFBundleVersion"] as? String {
            devVersionLabel.text = "Development Version Build " + version
        }

        timeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let startDate = self.user?.currentPart?.start?.time {
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.hour, .minute]
                formatter.unitsStyle = .abbreviated

                self.timeLabel.text = formatter.string(from: Date().timeIntervalSince(startDate))
            } else {
                self.timeLabel.text = "--:--"
            }
        }
        timeTimer?.fire()

        dataController.save()
        displayCurrentPart()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displayCurrentPart()
        if user?.currentPart == nil {
            boardUnboardButton.setTitle("Einsteigen", for: .normal)
        } else {
            boardUnboardButton.setTitle("Aussteigen", for: .normal)
        }
        journeyTableView.reloadData()
    }

    func displayCurrentPart() {
        quitJourneyButton.isEnabled = (user?.currentJourney?.parts?.count ?? 0) > 0

        guard let currentPart = user?.currentPart else {
            stationLabel.text = ""
            trainLabel.text = "---"
            sinceLabel.text = "---"
            return
        }

        stationLabel.text = currentPart.start?.station?.name
        trainLabel.text = currentPart.train?.stringRepresentation()
        if let sinceDate = currentPart.start?.time {
            sinceLabel.text = "seit " + DateFormatter.localizedString(from: sinceDate, dateStyle: .none, timeStyle: .short)
        }
    }

    @IBAction func quitJourneyButtonPressed(_ sender: Any) {
        if let cJourney = user?.currentJourney, (cJourney.parts?.count ?? 0) > 0 {
            user?.addToJourneys(cJourney)
            cJourney.currentOfUser = nil
            cJourney.forUser = user

            user?.currentJourney = dataController.makeJourney()
            user?.currentJourney?.currentOfUser = user
            dataController.save()
            journeyTableView.reloadData()
        }
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (user?.currentJourney?.parts?.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reusedCell = tableView.dequeueReusableCell(withIdentifier: "cj")
        if reusedCell == nil {
            reusedCell = CJTableViewCell()
        }
        guard let cell = reusedCell as? CJTableViewCell else {
            fatalError("Could not create new cell")
        }
        let ind = indexPath.last!
        guard let len = user?.currentJourney?.parts?.count else {
            fatalError("No journey")
        }
        guard let part = user?.currentJourney?.parts?.array[len-1-ind] as? JourneyPart else {
            fatalError("No events")
        }
        cell.displayPart(part: part)
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if  let len = user?.currentJourney?.parts?.count,
                let toBeDeleted = user?.currentJourney?.parts?.array[len-1-indexPath.row] as? JourneyPart {
                user?.currentJourney?.removeFromParts(toBeDeleted)
                dataController.delete(toBeDeleted)
                dataController.save()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

        }
    }
}
