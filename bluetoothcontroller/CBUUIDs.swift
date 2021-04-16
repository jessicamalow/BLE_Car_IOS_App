//
//  CBUUIDs.swift
//  bluetoothcontroller
//
//  Created by Jessica Malow on 3/24/21.
//

import Foundation
import CoreBluetooth

struct CBUUIDs{

    static let kBLEService_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
    static let kBLE_Characteristic_uuid_Tx = "beb5483e-36e1-4688-b7f5-ea07361b26a8"
    static let kBLE_Characteristic_uuid_Rx = "beb5483e-36e1-4688-b7f5-ea07361b26a8"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)

}
