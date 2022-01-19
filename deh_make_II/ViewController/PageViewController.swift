//
//  PageViewController.swift
//  UItest1010
//
//  Created by Ray Chen on 2017/12/28.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource {
    var pageHeading = [
        NSLocalizedString("DEH Make's Homepage", comment: ""),
        NSLocalizedString("User login screen", comment: ""),
        NSLocalizedString("Make Image POI", comment: ""),
        NSLocalizedString("Make Audio POI", comment: ""),
        NSLocalizedString("Make Movie POI", comment: ""),
        NSLocalizedString("Attractions temporary list", comment: ""),
        NSLocalizedString("Attractions upload operation", comment: "")
    ]
    
    var contentText = [
        NSLocalizedString("This is our homepage!\nYou can enter the login screen from the top right corner keys\nAlso, you can enter the scenic spots from below", comment: ""),
        NSLocalizedString("Log in to your account\nPlace your attraction into your account.", comment: ""),
        NSLocalizedString("Make your own photo POI\nIf you want to explain the content can also be voice assisted", comment: ""),
        NSLocalizedString("Make your own audio POI\nIf you want to explain the content can also be voice assisted", comment: ""),
        NSLocalizedString("Make your own video POI\nIf you want to explain the content can also voice assistance", comment: ""),
        NSLocalizedString("The POI will be displayed in the list when they are finished\nPlease wait for your later edits and uploads", comment: ""),
        NSLocalizedString("Silence the action you want\nSwipe left to upload and delete", comment: ""),
    ]
    var contentImage = ["page1", "page2", "page3", "page4", "page5", "page6", "page7", ]

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //self.navigationController.navigationBarHidden=YES
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self
        
        if let startingViewController = contentPageViewControllerAtIndex(index: 0){
            setViewControllers(
                [startingViewController],
                direction: .forward,
                animated: true,
                completion: nil
            )
            
            self.view.frame = CGRect(
                x: 0,
                y: 0,
                width: self.view.frame.size.width,
                height: self.view.frame.size.height - 30
            )
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).index
        
        index = index + 1
        return contentPageViewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! PageContentViewController).index
        
        index = index - 1
        return contentPageViewControllerAtIndex(index: index)
    }
    
    func contentPageViewControllerAtIndex(index: Int) -> PageContentViewController? {
        if index == NSNotFound || index < 0 || index >= pageHeading.count {
            return nil
        }
        
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "pageContentViewController") as? PageContentViewController {
            pageContentViewController.pageHeading = pageHeading[index]
            pageContentViewController.contenText = contentText[index]
            pageContentViewController.contenImage = contentImage[index]
            pageContentViewController.index = index
            
            return pageContentViewController
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
