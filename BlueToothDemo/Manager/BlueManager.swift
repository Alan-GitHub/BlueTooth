//
//  BlueManager.swift
//  BlueToothDemo
//
//  Created by HCP-Company on 2020/3/27.
//  Copyright © 2020 HCP-Company. All rights reserved.
//

import Foundation
import CoreBluetooth

//中心代理方法
protocol BlueManagerCentralDelegate: NSObjectProtocol {
    func didUpdateDevices(devices: [CBPeripheral])
}

extension BlueManagerCentralDelegate {
    func didUpdateDevices(devices: [CBPeripheral]){}
}

//外设代理方法
protocol BlueManagerPeripheralDelegate: NSObjectProtocol {
    func didUpdateDeviceCharacteristic(characterKeyValue: [(CBUUID, String)])
}

extension BlueManagerPeripheralDelegate {
    func didUpdateDeviceCharacteristic(characterKeyValue: [(CBUUID, String)]){}
}

final class BlueManager: NSObject {
    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    
    //存储扫描到的蓝牙设备
    private var blueToothDevices = [CBPeripheral]()
    //存储某个蓝牙设备的所有特征（Key-Value类型）
    private var gCharacterKeyValue = [(CBUUID, String)]()
    
    //中心代理
    weak var centralDelegate: BlueManagerCentralDelegate?
    //外设代理
    weak var peripheralDelegate: BlueManagerPeripheralDelegate?
    
    //单例模式
    static let share: BlueManager = BlueManager()
    
    func startScan() {
        //再次扫描之前，先清除所有缓存数据
        blueToothDevices.removeAll()
        gCharacterKeyValue.removeAll()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func stopScan() {
        centralManager?.stopScan()
    }
    
    func connectPeripheral(peripheral: CBPeripheral) {
        gCharacterKeyValue.removeAll()
        
        centralManager?.connect(peripheral, options: nil)
    }
}

extension BlueManager: CBCentralManagerDelegate {
    //初始化CBCentralManager后会自动调用
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
        switch central.state {
        case .unknown:
            ()
        case .resetting:
            ()
        case .unsupported:
            ()
        case .unauthorized:
            ()
        case .poweredOff:
            ()
        case .poweredOn:
            //扫描外围设备， 只有在poweredOn下才可以扫描
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        default:
            ()
        }
    }
    
    //扫描到设备回调
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Find device \(peripheral.name ?? "")")
        
        if !blueToothDevices.contains(peripheral), peripheral.name?.isEmpty == false {
            blueToothDevices.append(peripheral)
            centralDelegate?.didUpdateDevices(devices: blueToothDevices)
        }
    }
    
    //已经连接外设回调
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //停止扫描
        stopScan()
        
        //设置代理
        peripheral.delegate = self
        self.peripheral = peripheral
        //扫描外设的服务
        peripheral.discoverServices(nil)
    }
    
    //连接外设失败回调
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
    
    //取消与外设连接的回调
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print(peripheral.name ?? "")
    }
}

extension BlueManager: CBPeripheralDelegate {
    //扫描到外设服务的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("已经扫描到外设服务～")
        
        for service in peripheral.services ?? [] {
            print(service)
            //扫描外设特征
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //扫描到服务特征回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("已经扫描到外设服务特征～")
  
        for character in service.characteristics ?? [] {
            print(character)
            //如果是自己要用的特征UUID
            /*
            if characteristic.uuid.isEqual(CBUUID(string: "")) {
                //读一次，针对值不变的情况，读取成功会回调方法didUpdateValueForCharacteristic
                peripheral.readValue(for: characteristic)
                
                //订阅，实时接收值，针对值经常变化的情况，设置成功，如果有接收到新值，会回调方法didUpdateNotificationStateForCharacteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
            */
            
            peripheral.readValue(for: character)

            //扫描外设characteristics的descriptor
            //peripheral.discoverDescriptors(for: characteristic)
        }
    }
    
    //获取值
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("获取characteristic值")
        //characteristic.value就是蓝牙给我们的值
        guard let data = characteristic.value else { return }
        
        let value = String(data: data, encoding: String.Encoding.utf8) ?? ""
        gCharacterKeyValue.append((characteristic.uuid, value))
        
        peripheralDelegate?.didUpdateDeviceCharacteristic(characterKeyValue: gCharacterKeyValue)
    }
    
    //获取外设实时数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.isNotifying {
            peripheral.readValue(for: characteristic)
        } else {
            print("Notification stopped on \(characteristic). Disconnecting")
            print(characteristic)
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    //数据写入成功回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("数据写入成功...")
    }
}
