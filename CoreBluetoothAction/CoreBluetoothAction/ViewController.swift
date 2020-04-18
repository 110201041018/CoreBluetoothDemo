//
//  ViewController.swift
//  CoreBluetoothAction
//
//  Created by EzioChan on 2020/4/10.
//  Copyright © 2020 EzioChan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func asCentralBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "asCentral", sender: nil)
    }
    
    @IBAction func asPeripheralBtnAction(_ sender: Any) {
        performSegue(withIdentifier: "asPeripheral", sender: nil)
    }
    
}

