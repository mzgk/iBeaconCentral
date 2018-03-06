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
    static let proximityUUID: UUID = UUID(uuidString: "7A6CFE30-DF2B-4C04-8B6A-0180F73D64CD")!
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
}
