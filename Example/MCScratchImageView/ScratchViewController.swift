//
//  ScratchViewController.swift
//  MCScratchImageView
//
//  Created by Minecode on 2017/12/27.
//  Copyright © 2017年 Minecode. All rights reserved.
//

import UIKit

class ScratchViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scratchImageView: MCScratchImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        setupView()
    }
    
    func setupView() {
        imageView.image = UIImage(named: "bonus2.png")
        
        scratchImageView!.setMaskImage(UIImage(named: "bonus2-scratch.png")!)
        scratchImageView!.delegate = self
    }
    
   @IBAction func scratchedHandler(_ sender: UIButton) {
        scratchImageView.scratchAll()
        print("Scratched")
        sender.isEnabled = false
    }

}

extension ScratchViewController: MCScratchImageViewDelegate {
    
    func mcScratchImageView(_ mcScratchImageView: MCScratchImageView, didChangeProgress progress: CGFloat) {
        
        print("Progress did changed: " + String(format: "%.2f", progress))
        
        if (progress >= 0.8) {
            mcScratchImageView.scratchAll()
        }
        
    }
    
}
