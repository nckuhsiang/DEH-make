//
//  PageContentViewController.swift
//  DEH-Make-II
//
//  Created by Ray Chen on 2017/12/28.
//  Copyright © 2017年 Ray Chen. All rights reserved.
//

import UIKit
//MARK: 疑似沒有作用
class PageContentViewController: UIViewController {

    @IBOutlet weak var pageHeadingLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var leftButton: UIButton!
    
    var index = 0
    var pageHeading = ""
    var contenText = ""
    var contenImage = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        pageControl.currentPage = index
        pageHeadingLabel.text = pageHeading
        contentLabel.text = contenText
        contentImageView.image = UIImage(named: contenImage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
