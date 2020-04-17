//
//  PeripheralMgrViewController.swift
//  CoreBluetoothAction
//
//  Created by EzioChan on 2020/4/15.
//  Copyright © 2020 EzioChan. All rights reserved.
//

import UIKit
import CoreBluetooth



let serviceUUID1 = "EE00"
let notifyCharacteristicUUID = "EE01"
let readCharacteristicUUID =  "EE02"
let writeCharacteristicUUID = "EE03"
let LocalNameKey = "Gt_0"

class PeripheralMgrViewController: UIViewController ,CBPeripheralManagerDelegate{
   
    
    var timeAction:Timer!
    var phermgr:CBPeripheralManager!
    var cbmgr:CBManager!
    var didSendChara:CBCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phermgr = CBPeripheralManager.init(delegate: self, queue: nil, options: nil)
        
     
        
        
        //[CBAdvertisementDataIsConnectable:true,CBAdvertisementDataLocalNameKey:true,CBAdvertisementDataManufacturerDataKey:""]
        
        
        
        
    }
    
    @objc func sendData1(characteristic:CBCharacteristic){
        let date = Date.init()
        let dateformate = DateFormatter.init()
        dateformate.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let str = dateformate.string(from: date)
        let data = str.data(using:String.Encoding.utf8)!
        phermgr.updateValue(data, for: characteristic as! CBMutableCharacteristic, onSubscribedCentrals: nil)
    }
    
    @objc func sendData(){
         let date = Date.init()
         let dateformate = DateFormatter.init()
         dateformate.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let str = dateformate.string(from: date)
         let data = str.data(using:String.Encoding.utf8)!
         phermgr.updateValue(data, for: didSendChara as! CBMutableCharacteristic, onSubscribedCentrals: nil)
        print("sendData")
     }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case CBManagerState.poweredOn:  //蓝牙已打开正常
            NSLog("启动成功，开始搜索")
             //不限制
            let cbu = CBUUID.init(string:CBUUIDCharacteristicUserDescriptionString)
            
            //服务
            let service1 = CBMutableService.init(type: CBUUID.init(string: serviceUUID1), primary: true)
            
            let noti = CBMutableCharacteristic.init(type: CBUUID.init(string: notifyCharacteristicUUID), properties: .notify, value: nil, permissions: .readable)
            //特征值，只读
            let chart_0 = CBMutableCharacteristic.init(type: CBUUID.init(string: readCharacteristicUUID), properties: .read, value: nil, permissions: .readable)
            //特征值，只写
            let chart_1 = CBMutableCharacteristic.init(type: CBUUID.init(string: writeCharacteristicUUID), properties: .write, value: nil, permissions: .writeable)
            //描述符
            let des_0 = CBMutableDescriptor.init(type: cbu, value: "name")
            let des_1 = CBMutableDescriptor.init(type: cbu, value: "name")
            
            chart_0.descriptors = [des_0]
            chart_1.descriptors = [des_1]
            service1.characteristics = [chart_0,chart_1,noti]
            //增加1个服务
            phermgr.add(service1)

        case CBManagerState.unauthorized: //无BLE权限
            NSLog("无BLE权限")
        case CBManagerState.poweredOff: //蓝牙未打开
            NSLog("蓝牙未开启")
        default:
            NSLog("状态无变化")
        }
          
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("peripheralManager didAdd")
        //加入服务以后再打开广播
        peripheral.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[CBUUID.init(string: serviceUUID1)],CBAdvertisementDataLocalNameKey:LocalNameKey])
    }
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("peripheralManagerIsReady")
    }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("peripheralManagerDidStartAdvertising")
         
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("subscribe")
        //订阅成功之后我们给它发送一个数据
//        self.sendData(characteristic: characteristic)
        didSendChara = characteristic
        if (timeAction != nil) {
            timeAction.invalidate()
            timeAction = nil
        }
        timeAction = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(sendData), userInfo: nil, repeats: true)
//        timeAction.fire()
    }
    //收到读的请求
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        print("didReceiveRead")
        //最好做一下是否有读权限
        if request.characteristic.properties == CBCharacteristicProperties.read {
            
            request.value = Data.init(bytes: [0x02,0x03], count: 2)
            peripheral.respond(to: request, withResult: .success)
//            self.sendData(characteristic: request.characteristic)
        }else{
            peripheral.respond(to: request, withResult: .writeNotPermitted)
        }
        
    }
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("didReceiveWrite")
        let request = requests[0]
        for req in requests {
            print(req.characteristic.uuid.uuidString)
        }
       //先检查是否有写权限
        if request.characteristic.properties == .write {
            peripheral.respond(to: request, withResult: .success)
            
        }else{
            peripheral.respond(to: request, withResult: .writeNotPermitted)
        }
    }
    
    //取消订阅
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
    }
    

}
