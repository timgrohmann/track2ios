//
//  JourneyArchiveViewController.swift
//  TrackSquared
//
//  Created by Tim Grohmann on 18.11.18.
//  Copyright © 2018 Tim Grohmann. All rights reserved.
//

import UIKit

class JourneyArchiveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var archiveTableView: UITableView!
    
    var journeys: [Journey] = []
    
    let dataController = DataController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        journeys = dataController.getUser().journeys?.allObjects as! [Journey]
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! SingleJourneyHistoryViewController
        if let j = sender as? Journey {
            dest.setJourney(journey: j)
        }
        archiveTableView.selectRow(at: nil, animated: true, scrollPosition: .top)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "selectJourney", sender: journeys[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCell(withIdentifier: "journeyCell")
        if c == nil {
            c = JourneyArchiveTableViewCell()
        }
        guard let cell = c as? JourneyArchiveTableViewCell else {
            fatalError("Could not create new cell")
        }
        
        cell.display(journey: journeys[indexPath.row])
        return cell
    }

}
