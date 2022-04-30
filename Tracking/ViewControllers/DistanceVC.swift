//
//  DistanceVC.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import UIKit

class DistanceVC: UIViewController {

    @IBOutlet weak var distanceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        SpeedManager.shared.delegate = self
    }

}

extension DistanceVC: SpeedManagerDelegate{
    func speedDidChange(speed: Speed, distance: Double) {
        let strSpeed = String(format:"%.2f", distance)
        distanceLabel.text = "\(strSpeed)\nm/s"
    }
}
