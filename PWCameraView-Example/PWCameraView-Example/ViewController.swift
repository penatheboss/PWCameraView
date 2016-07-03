//
//  ViewController.swift
//  PWCameraView-Example
//
//  Created by Pranav Wadhwa on 7/3/16.
//  Copyright © 2016 Pranav Wadhwa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        let camera = PWCameraView(frame: self.view.frame)
        self.view.addSubview(camera)
        camera.reload()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

