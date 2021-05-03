//
//  ScanTableViewCell.swift
//  bluetoothcontroller
//
//  Created by Jessica Malow and Nicole Malow on 3/24/21.
//

import UIKit
import CoreBluetooth

class scanTableCell: UITableViewCell {
    @IBOutlet weak var identifier: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var state: UILabel!
    var peri:CBPeripheral?
    
    func initiatecells(identifiers: String, names: String, states: String) {
        identifier.text = identifiers
        name.text = names
        state.text = states
    }
}
