//
//  ViewController.swift
//  BlueToothDemo
//
//  Created by Alan Turing on 2020/3/24.
//  Copyright © 2020 Alan Turing. All rights reserved.
//

import UIKit
import CoreBluetooth
import SnapKit

class ViewController: UIViewController {
    
    private lazy var scanBtn: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        btn.setTitle("开始扫描", for: UIControl.State.normal)
        btn.setTitle("停止扫描", for: UIControl.State.selected)
        btn.setTitleColor(UIColor.red, for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        btn.addTarget(self, action: #selector(scanBtnClick), for: UIControl.Event.touchUpInside)
        
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ac = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        
        return ac
    }()
    
    private lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        return tb
    }()
    private var tableData = [CBPeripheral]()
    
    deinit {
        print("ViewController deinit...")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        commonInit()
        setupUI()
        setupConstraints()
    }
    
    func commonInit() {
        BlueManager.share.centralDelegate = self
        
        //添加扫描按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: scanBtn)
    }
    
    @objc func scanBtnClick(btn: UIButton) {
        if btn.isSelected {
            stopScanBlue()
        } else {
            startScanBlue()
        }
    }
    
    func startScanBlue() {
        BlueManager.share.startScan()
        
        scanBtn.isSelected = true
        activityIndicator.startAnimating()
    }
    
    func stopScanBlue() {
        BlueManager.share.stopScan()
        
        scanBtn.isSelected = false
        activityIndicator.stopAnimating()
    }
    
    func setupUI() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = tableData[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        stopScanBlue()
   
        let vc = BlueDeviceDetailViewController()
        vc.peripheral = tableData[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: BlueManagerCentralDelegate {
    func didUpdateDevices(devices: [CBPeripheral]) {
        tableData = devices
        tableView.reloadData()
    }
}

//扩展方法
extension ViewController {
    //给外设发送（写入）数据, 发送检查蓝牙命令
    func writeCheckBleWithBle() {
//        let data = "".data(using: String.Encoding.utf8)
//        peripheral?.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withResponse)
    }
}


