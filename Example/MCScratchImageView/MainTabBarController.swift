//
//  MainTabBarController.swift
//  MCScratchImageView
//
//  Created by Minecode on 2017/12/27.
//  Copyright © 2017年 Minecode. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupChildView()
    }
    
    func setupChildView() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = storyBoard.instantiateViewController(withIdentifier: "ScratchVC")
        vc1.tabBarItem.title = "Default"
        vc1.tabBarItem.image = UIImage(named: "barItem")
        vc1.tabBarItem.selectedImage = UIImage(named: "barItem_selected")
        self.addChildViewController(vc1)
        
        let vc2 = storyBoard.instantiateViewController(withIdentifier: "CustomScratchVC")
        vc2.tabBarItem.title = "Custom"
        vc2.tabBarItem.image = UIImage(named: "barItem")
        vc2.tabBarItem.selectedImage = UIImage(named: "barItem_selected")
        self.addChildViewController(vc2)
        
        let vc3 = storyBoard.instantiateViewController(withIdentifier: "PopScratchVC")
        vc3.tabBarItem.title = "ScratchVC"
        vc3.tabBarItem.image = UIImage(named: "barItem")
        vc3.tabBarItem.selectedImage = UIImage(named: "barItem_selected")
        self.addChildViewController(vc3)
    }

}
