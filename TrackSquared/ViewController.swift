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
    @IBOutlet weak var journeyTableView: UITableView!
    
    let dc = DataController()
    
    
    var user: User?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dc.prepare()
        
        
        let userFetch: NSFetchRequest<User> = NSFetchRequest(entityName: "User")
        var users: [User] = []
        do {
            users = try managedObjectContext.fetch(userFetch)
        } catch {
            fatalError("User could not be fetched/created: \(error)")
        }
        
        /*if users.count == 1 {
            managedObjectContext.delete(users[0])
            users = []
        }*/
        
        if users.count == 1 {
            user = users[0]
            //user?.currentPart = nil
            //managedObjectContext.delete(journeys[0])
        } else {
            //DEBUG CODE
            let station = dc.getStation(code: "RM")!
            let station2 = dc.getStation(code: "BL")!
            
            
            let ev1 = TrainEvent(context: managedObjectContext)
            ev1.station = station
            ev1.time = Date(timeIntervalSinceNow: -60 * 60 * 24 * 5)
            ev1.scheduledTime = ev1.time
            let ev2 = TrainEvent(context: managedObjectContext)
            ev2.station = station2
            ev2.time = Date(timeIntervalSinceNow: -60)
            ev2.scheduledTime = ev2.time
            
            let part = JouneyPart(context: managedObjectContext)
            part.start = ev1
            part.goal = ev2
            
            let journey = Journey(context: managedObjectContext)
            journey.addToParts(part)
            
            let cPart = JouneyPart(context: managedObjectContext)
            cPart.start = TrainEvent(context: managedObjectContext)
            cPart.start?.time = Date()
            cPart.start?.station = station2
            cPart.start?.scheduledTime = cPart.start?.time
            
            user = User(context: managedObjectContext)
            user?.currentJourney = journey
            journey.forUser = user
            
            
            print("Added new j")
        }
        
        
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let infoDict = NSDictionary(contentsOfFile: path),
            let v = infoDict["CFBundleVersion"] as? String{
            devVersionLabel.text = "Development Version Build " + v
        }

        delegate.saveContext()
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (user?.currentJourney?.parts?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCell(withIdentifier: "cj")
        if c == nil {
            c = CJTableViewCell()
        }
        guard let cell = c as? CJTableViewCell else {
            fatalError("Could not create new cell")
        }
        let ind = indexPath.last!
        guard let len = user?.currentJourney?.parts?.count else {
            fatalError("No journey")
        }
        guard let part = user?.currentJourney?.parts?.array[len-1-ind] as? JouneyPart,
              let start = part.start,
              let goal = part.goal else {
            fatalError("No events")
        }
        cell.displayPart(t1: start, t2: goal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if  let len = user?.currentJourney?.parts?.count,
                let p = user?.currentJourney?.parts?.array[len-1-indexPath.row] as? JouneyPart {
                user?.currentJourney?.removeFromParts(p)
                managedObjectContext.delete(p)
                delegate.saveContext()
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        }
    }

}

