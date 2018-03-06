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

    // 手順２：モニタリングが正常に開始された
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 手順３：問い合わせ
        locationManager.requestState(for: region)
    }

    // 手順４：Regionの状態を取得
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard let region = region as? CLBeaconRegion else {
            return
        }
        switch state {
        case .inside:
            // 手順５：レンジングを開始
            locationManager.startRangingBeacons(in: region)
        case .outside:
            locationManager.stopRangingBeacons(in: region)
        case .unknown:
            break
        }
    }

    // 手順６：情報を取得
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            let validBeacon = (beacon.proximityUUID, beacon.major as! CLBeaconMajorValue, beacon.minor as! CLBeaconMinorValue)
            if validBeacon == MyBeacon.myBeacon {
                if beacon.proximity == .immediate ||
                    beacon.proximity == .near {
                    // Beacon端末ごとにUUID,Major,Minorが違わないので距離で判定
                    // TODO: 対象なので通知を出す
                    sendNotification(message: "iBeaconを受信")
                    locationManager.stopRangingBeacons(in: region)
                }
            }
        }
    }

    // 領域内に入った
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        // 手順５：レンジングを開始
        locationManager.startRangingBeacons(in: region as! CLBeaconRegion)
    }

    // 領域から出た
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationManager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }

    func sendNotification(message: String) {
        // トリガー
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
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
