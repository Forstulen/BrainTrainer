//
//  TimeAttackViewController.swift
//  Count
//
//  Created by Romain Tholimet on 10/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import UIKit

class TimeAttackViewController: UIViewController {
    
    //MARK: Properties
    var shouldNotify : Bool = false
    
    @IBOutlet weak var personalBestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.personalBestLabel.text = CalculationManager.shared().getPersonalBest()
    }
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismissModal()
    }
    
    @IBAction func startTimeAttack(_ sender: Any) {
        CalculationManager.shared().setMode(mode: .timeAttack)
        self.dismissModal(shouldNotify: true)
    }

    //MARK: Private Methods
    private func dismissModal(shouldNotify : Bool = false) {
        dismiss(animated: true) {
            if shouldNotify {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "timeAttackModalIsDimissed"), object: nil)
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
