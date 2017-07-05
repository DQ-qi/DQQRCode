//
//  ViewController.swift
//  DQQRCode
//
//  Created by dengqi on 2017/7/5.
//  Copyright © 2017年 XXX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageV: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let size = imageV.frame.size
        imageV.image = {
            var qrCode = dq_QRCode.init("hjgjh")
            qrCode?.size = size
            return qrCode?.image
            
        }()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

