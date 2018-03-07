//
//  ViewController.swift
//  iBeaconCentral
//
//  Created by mzgk on 2018/03/06.
//  Copyright © 2018年 mzgk. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // 通知の許可
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                center.delegate = self
            }
        }

        // Beaconのモニタリング開始
        BeaconCentralManager.default.initLaunch()
        BeaconCentralManager.default.startMonitoring()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

