//
//  CustomScratchViewController.swift
//  MCScratchImageView
//
//  Created by Minecode on 2017/12/28.
//  Copyright © 2017年 Minecode. All rights reserved.
//

import UIKit

class CustomScratchViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scratchImageView: MCScratchImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        setupView()
    }
    
    func setupView() {
        imageView.image = UIImage(named: "bonus2.png")
        
        scratchImageView!.setMaskImage(UIImage(named: "bonus2-scratch.png")!, spotRadius: 100)
        scratchImageView!.delegate = self
    }
    
    @IBAction func scratchedHandler(_ sender: UIButton) {
        scratchImageView.scratchAll()
        print("Scratched")
        sender.isEnabled = false
    }
    
}

extension CustomScratchViewController: MCScratchImageViewDelegate {
    
    func mcScratchImageView(_ mcScratchImageView: MCScratchImageView, didChangeProgress progress: CGFloat) {
        print("Progress did changed: " + String(format: "%.2f", progress))
    }
    
}
