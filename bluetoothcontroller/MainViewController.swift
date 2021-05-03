//
//  ViewController.swift
//  bluetoothcontroller
//
//  Created by Jessica Malow and Nicole Malow on 3/23/21.
//

import UIKit
import CoreBluetooth

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet var joystickView: UIView!
    
    @IBOutlet var joystickUI: UIView!

    static let notificationName = Notification.Name("Joystick")

    //auto light switching mechanism
    @IBAction func autolightswitch(_ sender: UISwitch) {
        if (sender.isOn == true) {
            light.isEnabled = false;
            writeOutgoingValue(data: "auto")
        } else {
            light.isEnabled = true;
            writeOutgoingValue(data: "autooff")
        }
    }
    //Auto light end
    
    var manager:CBCentralManager? = nil
    var mainPeripheral:CBPeripheral? = nil
    var mainCharacteristic:CBCharacteristic? = nil
    var mainCharacteristicW:CBCharacteristic? = nil
    
    let BLEService = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    let BLECharacteristic = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    let BLECharacteristicW = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    // MARK: - CBCentralManagerDelegate Methods
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
    // MARK: CBPeripheralDelegate Methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            
            for service in peripheral.services! {
                
                print("Service found with UUID: " + service.uuid.uuidString)
                peripheral.discoverCharacteristics(nil, for: service)
                
                //device information service
                if (service.uuid.uuidString == "180A") {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
                //GAP (Generic Access Profile) for Device Name
                // This replaces the deprecated CBUUIDGenericAccessProfileString
                if (service.uuid.uuidString == "1800") {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
                
            }
        }
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print(service.characteristics![0])
        //Found service
        print(service.characteristics![1])
                for characteristic in service.characteristics! {
                    
                    if (characteristic.uuid.uuidString == BLECharacteristic) {
                        //we'll save the reference, we need it to write data
                        
                        mainCharacteristic = characteristic
                        
                        //Set Notify is useful to read incoming data async
                        
                        peripheral.setNotifyValue(true, for: characteristic)
                        print("setNotify")
                        print("Found Data Characteristic")
                    }
                    if (characteristic.uuid.uuidString == BLECharacteristicW) {
                        //we'll save the reference, we need it to write data
                        
                        mainCharacteristicW = characteristic
                        
                        //Set Notify is useful to read incoming data async
                        
                        peripheral.setNotifyValue(true, for: characteristic)
                        print("setNotify")
                        print("Found Data Characteristic")
                    }
                    
                }
        }
    //Encoder
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        var characteristicASCIIValue = NSString()
   
        guard characteristic == mainCharacteristicW,
   
        let characteristicValue = characteristic.value,
        let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }
   
        characteristicASCIIValue = ASCIIstring
   
        print("Value Recieved: \((characteristicASCIIValue as String))")
if (characteristic.uuid.uuidString == BLECharacteristicW) {
                //data recieved
                if(characteristic.value != nil) {
                    let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8)!
                
                    message.text = stringValue
                }        }
    }
        

    
    func writeOutgoingValue(data: String){
          
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        
        if let bluefruitPeripheral = mainPeripheral {
              
          if let txCharacteristic = mainCharacteristic {
                  
            bluefruitPeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
              }
          }
      }
    
    func readIncomingValue() {
        
        if let bluefruitPeripheral = mainPeripheral {
              
          if let rxCharacteristic = mainCharacteristicW {
                  
            bluefruitPeripheral.readValue(for: rxCharacteristic)
              }
          }
      }


    @IBAction func sendHelloTapped(_ sender: Any) {
        writeOutgoingValue(data: "honk")
        
        let honk = "honk"
                let dataToSend = honk.data(using: String.Encoding.utf8)
                if (mainPeripheral != nil) {
                    print("data sent")
                    mainPeripheral?.writeValue(dataToSend!, for: mainCharacteristic!, type: CBCharacteristicWriteType.withResponse)
                } else {
                    print("haven't discovered device yet")
                }
    }
    
    @IBOutlet weak var light: UIButton!
    @IBAction func lightTapped(_ sender: Any) {
        if light.titleLabel?.text == "light" {
            writeOutgoingValue(data: "1")
            light.setTitle("off", for: .normal)
        } else {
            writeOutgoingValue(data: "0")
            light.setTitle("light", for: .normal)
        }
        
       
    }
    var lasttime = Date.init()
    let timepassed:TimeInterval = 0.05
    
    @objc func joystickMoved(notification:Notification) {
        print(notification.userInfo!)
        let currtime = Date.init()
        typealias TimeInterval = Double
        var daty = lasttime + timepassed
        if ((daty < currtime) || (notification.userInfo!["position"] as! String == "0,0")) {
            writeOutgoingValue(data: notification.userInfo!["position"] as! String)
            lasttime = currtime
        }
    }
    
    
    
    @IBOutlet weak var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joystickUI.layer.cornerRadius = 75
        // Do any additional setup after loading the view.
        manager = CBCentralManager(delegate: self, queue: nil)
        customiseNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(joystickMoved(notification:)), name: MainViewController.notificationName, object: nil)
    }
    func customiseNavigationBar() {
        self.navigationItem.rightBarButtonItem = nil
        
        let rightButton = UIButton()
        
        if (mainPeripheral == nil) {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
         if (segue.identifier == "scan-segue") {
            let scanController : ScanTableViewController = segue.destination as! ScanTableViewController
             
             //set the manager's delegate to the scan view so it can call relevant connection methods
             manager?.delegate = scanController
             scanController.manager = manager
             scanController.parentView = self
         }
         
     }
     
     // MARK: Button Methods
    @objc func scanButtonPressed() {
         performSegue(withIdentifier: "scan-segue", sender: nil)
     }
     
    @objc func disconnectButtonPressed() {
         //this will call didDisconnectPeripheral, but if any other apps are using the device it will not immediately disconnect
        print(mainPeripheral!)
        if mainPeripheral != nil {
        manager?.cancelPeripheralConnection(mainPeripheral!)
            print(mainPeripheral!)
            mainPeripheral = nil
            customiseNavigationBar()
        }
        
     }
    
    
}

