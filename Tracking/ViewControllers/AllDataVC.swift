//
//  AllDataVC.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import UIKit

class AllDataVC: UIViewController {

    @IBOutlet weak var tableData: UITableView!
    var arrayTracking = [TrackingModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SpeedManager.shared.delegate = self
        arrayTracking = DatabaseManager.shared.getData().reversed()
    }

}

extension AllDataVC: SpeedManagerDelegate{
    func speedDidChange(speed: Speed, distance: Double) {
        arrayTracking = DatabaseManager.shared.getData().reversed()
        DispatchQueue.main.async {
            self.tableData.reloadData()
        }
        
    }    
}

extension AllDataVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrayTracking.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackingCell") as! TrackingCell
        let data = arrayTracking[indexPath.row]
        let startTime = data.startTime.dateFromString()
        let stopTime = data.stopTime.dateFromString()
        cell.distanceLabel.text = data.distance
        cell.startTimeLabel.text = startTime?.stringFromDate()
        cell.stopTimeLabel.text = stopTime?.stringFromDate()
        cell.totalTimeLabel.text = AppConstants.getDateDiff(start: startTime, end: stopTime)
        return cell
    }
    
    
}
