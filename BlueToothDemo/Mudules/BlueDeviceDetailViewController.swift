//
//  BlueDeviceDetailViewController.swift
//  BlueToothDemo
//
//  Created by HCP-Company on 2020/3/27.
//  Copyright © 2020 HCP-Company. All rights reserved.
//

import UIKit
import CoreBluetooth

class BlueDeviceDetailViewController: UIViewController {
    var peripheral: CBPeripheral!
    
    private lazy var tableView: UITableView = {
        let tb = UITableView()
        tb.delegate = self
        tb.dataSource = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tb.separatorStyle = UITableViewCell.SeparatorStyle.none

        return tb
    }()
    private var tableData = [(CBUUID, String)]()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ac = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        
        return ac
    }()
    
    deinit {
        print("BlueDeviceDetailViewController deinit...")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        commonInit()
        setupUI()
        setupConstraints()
    }
    
    func commonInit() {
        BlueManager.share.peripheralDelegate = self
        self.title = peripheral.name
        BlueManager.share.connectPeripheral(peripheral: peripheral)
        
        activityIndicator.startAnimating()
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

extension BlueDeviceDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = tableData[indexPath.section].1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(tableData[section].0)"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BlueDeviceDetailViewController: BlueManagerPeripheralDelegate {
    func didUpdateDeviceCharacteristic(characterKeyValue: [(CBUUID, String)]) {
        tableData = characterKeyValue
        tableView.reloadData()
        
        activityIndicator.stopAnimating()
    }
}
