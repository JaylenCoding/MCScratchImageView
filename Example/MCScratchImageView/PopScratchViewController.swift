//
//  PopScratchViewController.swift
//  MCScratchImageView
//
//  Created by Minecode on 2017/12/28.
//  Copyright © 2017年 Minecode. All rights reserved.
//

import UIKit

class PopScratchViewController: UIViewController {
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scratchImageView: MCScratchImageView!
    @IBOutlet weak var popUpViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var popUpViewHeightCons: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        imageView.image = UIImage(named: "bonus1.png")
        
        scratchImageView!.setMaskImage(UIImage(named: "bonus1-scratch.png")!, spotRadius: 30)
        scratchImageView!.delegate = self
    }
    
    @IBAction func popUpHandler(_ sender: UIButton) {
        self.popUpViewTopCons.constant = -self.popUpViewHeightCons.constant
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        sender.isEnabled = false
    }
    
    @IBAction func closeHandler(_ sender: UIButton) {
        self.popUpViewTopCons.constant = 50
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        sender.isEnabled = false
    }
    
    
}

extension PopScratchViewController: MCScratchImageViewDelegate {
    
    func mcScratchImageView(_ mcScratchImageView: MCScratchImageView, didChangeProgress progress: CGFloat) {
        
        print("Progress did changed: " + String(format: "%.2f", progress))
        
    }
    
}
