//
//  MyBeacon.swift
//  iBeaconCentral
//
//  Created by mzgk on 2018/03/06.
//  Copyright © 2018年 mzgk. All rights reserved.
//

import Foundation
import CoreBluetooth
import CoreLocation

class MyBeacon {
    static let proximityUUID: UUID = UUID(uuidString: "92CEC608-0C60-4DCD-98C4-8EF57C09EBDE")!
    static let major: CLBeaconMajorValue = 1
    static let minor: CLBeaconMinorValue = 1
    static let identifier: String = "com.mzgkworks"

    static var beaconRegion: CLBeaconRegion {
        return CLBeaconRegion(
            proximityUUID: self.proximityUUID,
            major: self.major,
            minor: self.minor,
            identifier: self.identifier
        )
    }

    // 対象の比較用
    static var myBeacon: (UUID, CLBeaconMajorValue, CLBeaconMinorValue) {
        return (self.proximityUUID, self.major, self.minor)
    }
}
