//
//  ScanTableViewController.swift
//  bluetoothcontroller
//
//  Created by Jessica Malow on 3/23/21.
//

import Foundation
import UIKit
import CoreBluetooth

class ScanTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var periTableView: UITableView!
    
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:MainViewController? = nil
    private var bluefruitPeripheral: CBPeripheral!
    
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        periTableView.delegate = self
        periTableView.dataSource = self
        definesPresentationContext = true
        
    }
    
    //Jess
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
            scanBLEDevices()
        }

    // MARK: - Table view data source
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let peripheral : CBPeripheral
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanTableCell", for: indexPath) as! scanTableCell
        peripheral = peripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        cell.initiatecells(identifiers: "", names: peripheral.name ?? "", states: "")
        
        return cell
    }
    


        // MARK: BLE Scanning
        func scanBLEDevices() {
            manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
            
            //stop scanning after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3000) {
                self.stopScanForBLEDevices()
            }
        }
        
        func stopScanForBLEDevices() {
            manager?.stopScan()
        }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let peripheral = peripherals[indexPath.row]
        
        bluefruitPeripheral = peripheral
            bluefruitPeripheral.delegate = self
         
            print("Peripheral Discovered: \(peripheral)")
              print("Peripheral name: \(peripheral.name)")
            
            manager?.connect(bluefruitPeripheral!, options: nil)
//        manager?.connect(peripheral, options: nil)
        }


        // MARK: - CBCentralManagerDelegate Methods
    private func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
            
            if(!peripherals.contains(peripheral)) {
                peripherals.append(peripheral)
            }
            
        self.periTableView.reloadData()
        
        
        }
        
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {
              case .unknown:
                print("central.state is .unknown")
              case .resetting:
                print("central.state is .resetting")
              case .unsupported:
                print("central.state is .unsupported")
              case .unauthorized:
                print("central.state is .unauthorized")
              case .poweredOff:
                print("central.state is .poweredOff")
              case .poweredOn:
                print("central.state is .poweredOn")
                manager?.scanForPeripherals(withServices: nil)
            }
//            print(central.state)
        }
    //WORKS
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
            print("added")
        }
        self.periTableView.reloadData()
        
        
        
    }
    
        
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            bluefruitPeripheral.discoverServices([CBUUIDs.BLEService_UUID])
            //pass reference to connected peripheral to parent view
            parentView?.mainPeripheral = peripheral
            peripheral.delegate = parentView
            peripheral.discoverServices(nil)
            
            //set the manager's delegate view to parent so it can call relevant disconnect methods
            manager?.delegate = parentView
            parentView?.customiseNavigationBar()
            
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
            
            print("Connected to " +  peripheral.name!)
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            print("*******************************************************")

            if ((error) != nil) {
                print("Error discovering services: \(error!.localizedDescription)")
                return
            }
            guard let services = peripheral.services else {
                return
            }
            //We need to discover the all characteristic
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            print("Discovered Services: \(services)")
        }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           
               guard let characteristics = service.characteristics else {
              return
          }

          print("Found \(characteristics.count) characteristics.")

          for characteristic in characteristics {

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {

              rxCharacteristic = characteristic

              peripheral.setNotifyValue(true, for: rxCharacteristic!)
              peripheral.readValue(for: characteristic)

              print("RX Characteristic: \(rxCharacteristic.uuid)")
            }

            if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
              
              txCharacteristic = characteristic
              
              print("TX Characteristic: \(txCharacteristic.uuid)")
            }
          }
    }
        
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
        }
    
//    //Jess
////
////    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return events.count
////    }
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        let event : Event
////        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeCell
////            event = events[indexPath.row]
//
//        cell.setEvent(event: event)
//        return cell
//    }
//

}





