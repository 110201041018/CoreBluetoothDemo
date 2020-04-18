//
//  PeripheralViewController.swift
//  CoreBluetoothAction
//
//  Created by EzioChan on 2020/4/14.
//  Copyright © 2020 EzioChan. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController ,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var peripheralTable: UITableView!
    var mainPeripheral:CBPeripheral!
    var character:CBCharacteristic!
    override func viewDidLoad() {
        super.viewDidLoad()
        mainPeripheral.delegate = self
        
        peripheralTable.dataSource = self
        peripheralTable.delegate = self
        peripheralTable.register(UITableViewCell.self, forCellReuseIdentifier: "peripheral")
        peripheralTable.tableFooterView = UIView.init()
        
        
    }
    
    @IBAction func servicesBtnAction(_ sender: Any) {
        mainPeripheral.discoverServices(nil)
    }
    
    //服务发现回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            
            peripheral.discoverCharacteristics(nil, for: service)
            print(service.uuid.uuidString,"services")
        }
    }
    //设备特征回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for character in service.characteristics! {
            print(character.uuid.uuidString,"characteristics")
            peripheral.setNotifyValue(true, for: character)//订阅所有特征值的通知
            peripheral.readValue(for: character)//读取所有特征值
            peripheral.discoverDescriptors(for: character)//读取所有特征值的描述符
        }
        peripheralTable.reloadData()
    }
    //更新特征值通知
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("\(characteristic.uuid.uuidString): \(characteristic.uuid.data)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        if characteristic.uuid.uuidString == "EE01" {
        if (characteristic.value != nil) {
            let k = String.init(data: characteristic.value!, encoding: String.Encoding.utf8)
                  print("\(characteristic.uuid.uuidString): \(k)")//收到来自通知的数据
        }
      
//        }
         
    }
    
    //特征描述符回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        for descriptor in characteristic.descriptors! {
            print(descriptor.uuid.uuidString,"descriptors")
        }
        peripheralTable.reloadData()
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("characteristic is writed!")
    }
    
    //服务名更改
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
    }
    //外设名字变更
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        
    }
    
    
    
///MARK TableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return mainPeripheral.services?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let service:CBService = mainPeripheral.services![section]
        let chara:[CBCharacteristic] = service.characteristics ?? []
        return chara.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let service:CBService = mainPeripheral.services![indexPath.section]
        let chara:[CBCharacteristic] = service.characteristics!
        let item = chara[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "peripheral")
        cell?.textLabel?.text = item.uuid.uuidString
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         let service:CBService = mainPeripheral.services![section]
        return service.uuid.uuidString
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service:CBService = mainPeripheral.services![indexPath.section]
        let chara:[CBCharacteristic] = service.characteristics!
        character = chara[indexPath.row]
    }
    
    
    @IBAction func readBtnAction(_ sender: Any) {
        if (character != nil) {
            mainPeripheral.readValue(for: character)
            //print(character.value)
        }
    }
    
    @IBAction func writeBtnAction(_ sender: Any) {
        if (character != nil) {
            let data = Data.init(bytes: [0x00,0x02], count: 2)
            mainPeripheral.writeValue(data, for: character, type: .withResponse)
        }
    }
    
}
