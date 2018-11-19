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
        
        self.title = String(format: "Reise am %@", DateFormatter.localizedString(from: (journey.parts!.array[0] as! JouneyPart).start!.time!, dateStyle: .short, timeStyle: .none))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journey?.parts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCell(withIdentifier: "historyCell")
        if c == nil {
            c = JourneyHistoryPartTableViewCell()
        }
        guard let cell = c as? JourneyHistoryPartTableViewCell else {
            fatalError("Could not create new cell")
        }
        if let part = journey?.parts?.array[indexPath.row] as? JouneyPart {
            cell.displayPart(part: part)
        }
        return cell
    }

}
