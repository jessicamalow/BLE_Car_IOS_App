//
//  ScanTableViewCell.swift
//  bluetoothcontroller
//
//  Created by Jessica Malow on 3/24/21.
//

import UIKit
import CoreBluetooth

class scanTableCell: UITableViewCell {
    @IBOutlet weak var identifier: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var state: UILabel!
    var peri:CBPeripheral?
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    func initiatecells(identifiers: String, names: String, states: String) {
        identifier.text = identifiers
        name.text = names
        state.text = states
    }
}
