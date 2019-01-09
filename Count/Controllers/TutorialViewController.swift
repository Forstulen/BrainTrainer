//
//  TutorialViewController.swift
//  Count
//
//  Created by Romain Tholimet on 12/08/18.
//  Copyright © 2018 tkm. All rights reserved.
//

import UIKit
import Pageboy

@objc protocol TutorialViewControllerDelegate: class {
    func didDismissTutorial(sender: TutorialViewController)
}

@objc class TutorialViewController: PageboyViewController, PageboyViewControllerDataSource{
    
    //
    // MARK: Constants
    //
    
    weak var tutorialDelegate:TutorialViewControllerDelegate!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var captionLabel: UILabel!
    
    let numberOfPages = 4
    
    //
    // MARK: Lifecycle
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        self.transition = Transition(style: .reveal, duration: 3.0)
        self.autoScroller.enable()
        self.isInfiniteScrollEnabled = true
        self.pageControl.numberOfPages = numberOfPages
        self.pageControl.currentPage = 0
    }
    
    @IBAction func returnMainMenu(_ sender: Any) {
        dismiss(animated: true) {
            
        }
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return numberOfPages
    }
    
    func viewController(for pageboyViewController: PageboyViewController, at index: PageboyViewController.PageIndex) -> UIViewController? {
        let storyboard = UIStoryboard(name: "TutorialStoryboard", bundle: Bundle.main)
        
        var viewController: TutorialContentViewController? = nil;
   
        viewController = storyboard.instantiateViewController(withIdentifier: "TutorialContentViewController\(index + 1)") as? TutorialContentViewController
            
        viewController!.index = index + 1
        return viewController!
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}


// MARK: PageboyViewControllerDelegate
extension TutorialViewController: PageboyViewControllerDelegate {
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, willScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        self.autoScroller.enable()
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollTo position: CGPoint, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        _ = navigationOrientation == .vertical
        self.autoScroller.enable()
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didScrollToPageAt index: PageboyViewController.PageIndex, direction: PageboyViewController.NavigationDirection, animated: Bool) {
        self.autoScroller.enable()
        self.pageControl.currentPage = index
    }
    
    func pageboyViewController(_ pageboyViewController: PageboyViewController, didReloadWith currentViewController: UIViewController, currentPageIndex: PageboyViewController.PageIndex) {
        self.autoScroller.enable()       
    }
}
