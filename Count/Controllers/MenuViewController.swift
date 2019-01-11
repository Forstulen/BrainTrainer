//
//  MenuViewController.swift
//  Count
//
//  Created by Romain Tholimet on 09/12/2018.
//  Copyright © 2018 Romain Tholimet. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var practiceButton: MenuButtonView!
    @IBOutlet weak var timeAttackButton: MenuButtonView!
    @IBOutlet weak var tutorialButton: MenuButtonView!
    
    //MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundImageView.alpha = 0.25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CalculationManager.shared().saveData()
    }
    
    //MARK: Actions
    @IBAction func launchTutorial(_ sender: Any) {
        let storyboard = UIStoryboard(name: "TutorialStoryboard", bundle: Bundle.main)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "TutorialViewController") as? TutorialViewController else {
            return
        }
        
        present(viewController, animated: true)
    }
    
    @IBAction func presentRandom(_ sender: Any) {
        CalculationManager.shared().setMode(mode: .random)
        
        performSegue(withIdentifier: "gameViewController", sender: self)
    }
    
    
    @IBAction func presentTimeAttack(_ sender: Any) {
        self.presentModal(viewControllerName: "TimeAttackViewController")
    }
    
    @IBAction func presentDifficulty(_ sender: Any) {
        self.presentModal(viewControllerName: "DifficultyViewController")
    }
    
    
    //MARK: Private Methods
    @objc private func handleDifficultyModal() {
        NotificationCenter.default.removeObserver(self)
        
        performSegue(withIdentifier: "gameViewController", sender: self)
    }
    
    @objc private func handleTimeAttackModal() {
        NotificationCenter.default.removeObserver(self)
        
        performSegue(withIdentifier: "gameViewController", sender: self)
    }
        
    private func presentModal(viewControllerName : String) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            
        guard let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerName) as? UIViewController else {
                return
            }
        
        switch viewControllerName {
            case "DifficultyViewController":
                NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.handleDifficultyModal),
                                                   name: NSNotification.Name(rawValue: "difficultyModalIsDimissed"),
                                                   object: nil)
            case "TimeAttackViewController":
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.handleTimeAttackModal),
                                                       name: NSNotification.Name(rawValue: "timeAttackModalIsDimissed"),
                                                       object: nil)
            default:
                break
        }
        
            
            
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
            
        present(viewController, animated: true)
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
