//
//  TabbarController.swift
//  Tracking
//
//  Created by Manish on 23/04/22.
//

import UIKit

class TabbarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(RedirectTOTab), name: .kRedirectToTab3, object: nil)
        // Do any additional setup after loading the view.
    }
    

    @objc func RedirectTOTab(){
        self.selectedIndex = 2
    }
    

}
