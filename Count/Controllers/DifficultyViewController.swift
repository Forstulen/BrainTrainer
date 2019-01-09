//
//  DifficultyViewController.swift
//  Count
//
//  Created by Romain Tholimet on 10/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import UIKit

class DifficultyViewController: UIViewController {

    //MARK: Properties
    var shouldNotify : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.dismissModal()
    }
    
    @IBAction func selectEasyMode(_ sender: Any) {
        CalculationManager.shared().setCurrentLevel(level: .easy)
        self.dismissModal(shouldNotify: true)
    }
    
    @IBAction func selectMediumMode(_ sender: Any) {
        CalculationManager.shared().setCurrentLevel(level: .medium)
        self.dismissModal(shouldNotify: true)
    }
    
    @IBAction func selectHardMode(_ sender: Any) {
        CalculationManager.shared().setCurrentLevel(level: .hard)
        self.dismissModal(shouldNotify: true)
    }
    
    //MARK: Private Methods
    private func dismissModal(shouldNotify : Bool = false) {
        dismiss(animated: true) {
            if shouldNotify {
                CalculationManager.shared().setMode(mode: .practice)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "difficultyModalIsDimissed"), object: nil)
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
