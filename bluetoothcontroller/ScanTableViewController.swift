//
//  ScanTableViewController.swift
//  bluetoothcontroller
//
//  Created by Jessica Malow and Nicole Malow on 3/23/21.
//

import Foundation
import UIKit
import CoreBluetooth

class ScanTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet var periTableView: UITableView!
    
    var peripherals:[CBPeripheral] = []
    var manager:CBCentralManager? = nil
    var parentView:MainViewController? = nil
    private var adafruitPeripheral: CBPeripheral!
    
    private var txCharacteristic: CBCharacteristic!
    private var rxCharacteristic: CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        periTableView.delegate = self
        periTableView.dataSource = self
        definesPresentationContext = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
            scanBLEDevices()
        }


    
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
        
        adafruitPeripheral = peripheral
            adafruitPeripheral.delegate = self
         
            print("Peripheral Discovered: \(peripheral)")
        print("Peripheral name: \(peripheral.name ?? "unknown")")
            
            manager?.connect(adafruitPeripheral!, options: nil)
        }



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
            @unknown default:
                print("Unknown")
            }
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
        }
        self.periTableView.reloadData()
    }
    
        func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
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
    }
        
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
        }

}





