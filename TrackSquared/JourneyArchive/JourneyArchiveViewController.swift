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
    
    var journeys: [Journey] {
        get {
            return user?.journeys?.allObjects as? [Journey] ?? []
        }
    }
    
    let dataController = DataController()
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = dataController.getUser()
        //journeys = dataController.getUser().journeys?.allObjects as! [Journey]
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let j = journeys[indexPath.row]
            let alert = UIAlertController()
            alert.addAction(UIAlertAction(title: "Löschen", style: .destructive, handler: {
                _ in
                self.user?.removeFromJourneys(j)
                self.dataController.delete(j)
                self.dataController.save()
                self.archiveTableView.deleteRows(at: [indexPath], with: .fade)
                }))
            alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}