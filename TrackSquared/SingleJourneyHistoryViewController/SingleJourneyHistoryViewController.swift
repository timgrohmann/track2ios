//
//  SingleJourneyHistoryViewController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 19.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class SingleJourneyHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var journey: Journey?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func setJourney(journey: Journey) {
        self.journey = journey

        if let startTime = (journey.parts!.array[0] as? JourneyPart)?.start?.time {
            self.title = String(format: "Reise am %@", DateFormatter.localizedString(from: startTime, dateStyle: .short, timeStyle: .none))
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journey?.parts?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var reusedCell = tableView.dequeueReusableCell(withIdentifier: "historyCell")
        if reusedCell == nil {
            reusedCell = JourneyHistoryPartTableViewCell()
        }
        guard let cell = reusedCell as? JourneyHistoryPartTableViewCell else {
            fatalError("Could not create new cell")
        }
        if let part = journey?.parts?.array[indexPath.row] as? JourneyPart {
            cell.displayPart(part: part)
        }
        return cell
    }

    @IBAction func makeCurrentAgainButtonPressed(_ sender: Any) {
        guard let journey = journey, let user = journey.forUser else {
            return
        }

        if user.currentJourney?.parts?.count == 0 && user.currentPart == nil {
            dataController.delete(user.currentJourney!)
            user.currentJourney = journey
            journey.currentOfUser = user
            journey.forUser = nil
            user.removeFromJourneys(journey)
            dataController.save()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

}
