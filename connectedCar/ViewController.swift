//
//  ViewController.swift
//  connectedCar
//
//  Created by i830729 on 1/4/17.
//  Copyright © 2017 i830729. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,
    CBCentralManagerDelegate,
    CBPeripheralDelegate
{

    var manager:CBCentralManager!
    var peripheral:CBPeripheral!

    let BEAN_NAME = "Bluno"
    let UUID = CBUUID(string: "7AE7514F-9C8D-4A58-9E0D-290C4036F164")
    let SERVICE_UUID = CBUUID(string: "DFB1")

    
    @IBOutlet weak var dataLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)

        
        
    }

    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            print("1")
        } else {
            print("Bluetooth not available.")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        
        let device = (advertisementData as NSDictionary) .object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if device?.contains(BEAN_NAME) == true {
            self.manager.stopScan()
            
            self.peripheral = peripheral
            self.peripheral.delegate = self
            
            manager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(
        central: CBCentralManager,
        didConnectPeripheral peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
    
    func peripheral(
        peripheral: CBPeripheral,
        didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            print("3")
            if service.uuid == SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    func peripheral(
        peripheral: CBPeripheral,
        didDiscoverCharacteristicsForService service: CBService,
        error: NSError?) {
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            
            if thisCharacteristic.uuid == SERVICE_UUID {
                self.peripheral.setNotifyValue( true, for: thisCharacteristic)
            }
        }
    }
    
    func peripheral(
        peripheral: CBPeripheral,
        didUpdateValueForCharacteristic characteristic: CBCharacteristic,
        error: NSError?) {
        var count:UInt32 = 0;
        
        if characteristic.uuid == SERVICE_UUID {
            print(characteristic.value!)
            dataLabel.text = String(characteristic.value!.hashValue)
            //characteristic.value!.getBytes(&count, length: sizeof(UInt32))
            //dataLabel.text = NSString(format: "%llu", count) as String
        }
    }
    
    
    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    */

}
























