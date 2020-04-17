//
//  CentralViewController.swift
//  CoreBluetoothAction
//
//  Created by EzioChan on 2020/4/10.
//  Copyright © 2020 EzioChan. All rights reserved.
//

import UIKit
import CoreBluetooth


class CentralViewController: UIViewController,CBCentralManagerDelegate,UITableViewDelegate,UITableViewDataSource{
   
    @IBOutlet weak var listTable: UITableView!
    
    var centralMgr:CBCentralManager!
    var itemArray:Array<CBPeripheral>! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralMgr = CBCentralManager.init(delegate: self, queue: DispatchQueue.main, options: [CBConnectPeripheralOptionNotifyOnConnectionKey:true,CBConnectPeripheralOptionNotifyOnDisconnectionKey:true,CBConnectPeripheralOptionNotifyOnNotificationKey:true])
        listTable.delegate = self
        listTable.dataSource = self
        listTable.register(UITableViewCell.self, forCellReuseIdentifier: "table")
        listTable.tableFooterView = UIView.init()
        
    }
    
    @IBAction func searchBtnAction(_ sender: Any) {
        centralMgr.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
    }
    
    @IBAction func stopSearchBtnAction(_ sender: Any) {
        centralMgr.stopScan()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "table")!
        cell.textLabel?.text = itemArray[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = itemArray[indexPath.row]
        centralMgr.connect(item, options: [CBConnectPeripheralOptionNotifyOnConnectionKey:true,CBConnectPeripheralOptionNotifyOnDisconnectionKey:true])
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
           
    }
    
    /// 连接上了
    /// - Parameters:
    ///   - central: centerMgr
    ///   - peripheral: 蓝牙外设
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        performSegue(withIdentifier: "peripheralSegue", sender: peripheral)
    }
    
    /// 断开连接
    /// - Parameters:
    ///   - central: centerMgr
    ///   - peripheral: 蓝牙外设
    ///   - error: 错误原因
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }

    ///ANCS授权状态回调
    func centralManager(_ central: CBCentralManager, didUpdateANCSAuthorizationFor peripheral: CBPeripheral) {
        
    }
   
    
    /// 发现蓝牙设备回调
    /// - Parameters:
    ///   - central: centerMgr
    ///   - peripheral: 蓝牙外设
    ///   - advertisementData: 描述
    ///   - RSSI: 信号强度
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !itemArray.contains(peripheral) && (peripheral.name != nil){
            itemArray.append(peripheral)
            listTable.reloadData()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "peripheralSegue" {
            let vc = segue.destination as! PeripheralViewController
            vc.mainPeripheral = sender as? CBPeripheral
        }
    }
    


}
