//
//  BeaconCentralManager.swift
//  iBeaconCentral
//
//  Created by mzgk on 2018/03/06.
//  Copyright © 2018年 mzgk. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

import UserNotifications
import UIKit

protocol BeaconCentralManagerDelegate: class {
    func requestLocationAlways()
}

class BeaconCentralManager: NSObject {
    static let `default` = BeaconCentralManager()
    var delegate: BeaconCentralManagerDelegate?
    var locationManager = CLLocationManager()

    /// init
    override init() {
        super .init()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
    }

    /// ランチ時初期処理
    func initLaunch() {
    }

    /// モニタリング開始
    func startMonitoring() {
        let state = CLLocationManager.authorizationStatus()
        guard state == .authorizedAlways else {
            switch state {
            case .notDetermined:
                locationManager.requestAlwaysAuthorization()
            default:
                delegate?.requestLocationAlways()
                break
            }
            return
        }
        if isMonitoring() {
            return  // すでに監視中
        }
        // 手順１：モニタリングの開始
        locationManager.startMonitoring(for: MyBeacon.beaconRegion)
    }

    /// モニタリング停止
    func stopMonitoring() {
        if !isMonitoring() {
            return // 監視停止中なので
        }
        locationManager.stopMonitoring(for: MyBeacon.beaconRegion)
    }

    /// モニタリング判定
    func isMonitoring() -> Bool {
        for region in locationManager.monitoredRegions {
            if region.identifier == MyBeacon.identifier {
                return true
            }
        }
        return false
    }
}

extension BeaconCentralManager: CLLocationManagerDelegate {
    // 許可ステータスが更新された
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            startMonitoring()
        }
    }

    // 起動した時にすでに領域内にいた場合？（今回のケースではないパターン）　→ どういったタイミングでCallされるかは不明瞭
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        sendNotification(message: "モニタリング開始")
        print("モニタリング開始")
        locationManager.requestState(for: region)
    }

    // 手順２：領域内に入った
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        sendNotification(message: "領域内に入った")
        print("領域内に入った")
//        locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
    }

    // 手順５：領域から出た
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        sendNotification(message: "領域外に出た")
        print("領域外に出た")
//        locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }

    // 手順３・６：状態を確認
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let region = region as? CLBeaconRegion else {
            return
        }
        switch state {
        case .inside:
            // 手順３：内側なのでレンジングを開始
//            sendNotification(message: "iBeaconの状態確認：内")
            print("iBeaconの状態確認：内")
            locationManager.startRangingBeacons(in: region)
        case .outside:
            // 手順６：外側なのでレンジングを停止
//            sendNotification(message: "iBeaconの状態確認：外")
            print("iBeaconの状態確認：外")
            locationManager.stopRangingBeacons(in: region)
        case .unknown:
            break
        }
    }

    // 手順４：アドバタイズの情報を取得
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            let validBeacon = (beacon.proximityUUID, beacon.major as! CLBeaconMajorValue, beacon.minor as! CLBeaconMinorValue)
            if validBeacon == MyBeacon.myBeacon {
                sendNotification(message: "対象を確認！")
                print("対象を確認！")
//                locationManager.stopRangingBeacons(in: region)
            }
        }
    }


    /// ローカル通知
    func sendNotification(message: String) {
        // トリガー
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        // 内容
        let content = UNMutableNotificationContent()
        content.title = "iBeaconテスト"
        content.body = message
        content.sound = UNNotificationSound.default()
        // 登録
        let request = UNNotificationRequest(identifier: "uuid", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
