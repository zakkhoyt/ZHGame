//
//  BluetoothServer.swift
//  CoreBluetooth
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothServer: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate
{

	var manager: CBCentralManager!
	var peripheral: CBPeripheral?

	var data  = NSMutableData()

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////

	static let sharedInstance = BluetoothServer()
	
	private override init() {
		super.init()


	}
	
	func start() {
		self.manager = CBCentralManager(delegate: self, queue: nil)
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: scan API
	///////////////////////////////////////////////////////////////////////////////////////////////////

	func scanForPheripherals() {
		NSLog("scanning for peripherals...")

		self.manager.scanForPeripheralsWithServices([Bluetooth.Service], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
	}

	func stopScan() {
		self.manager.stopScan()
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: CBCentralManagerDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func centralManagerDidUpdateState(central: CBCentralManager) {
		guard central.state == .PoweredOn else {
			return NSLog("manager is not powered on")
		}
		self.scanForPheripherals()
	}
	
	func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		// Reject any where the value is above reasonable range
//		if RSSI.integerValue > -15 {
//			return
//		}
		// Reject if the signal strength is too low to be close enough (Close is around -22dB)
//		if RSSI.integerValue < -35 {
//			return
//		}

		if self.peripheral != peripheral {
			self.peripheral = peripheral
			NSLog("connecting to peripheral...")
			self.manager.connectPeripheral(self.peripheral!, options: nil)
		}
	}
	
	func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
		guard self.peripheral == peripheral else {
			return NSLog("could not connect to peripheral")
		}

		NSLog("connected: \(peripheral.name)")

		self.stopScan()
		self.data.length = 0
		peripheral.delegate = self
		peripheral.discoverServices([Bluetooth.Service])
	}
	
	func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		guard self.peripheral == peripheral else {
			return  NSLog("could not disconnect to peripheral")
		}

		NSLog("disconnected: \(peripheral.name)")
		self.peripheral = nil
		self.scanForPheripherals()
	}

	func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		NSLog("connection failed: \(error)")
		self.cleanup()
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: CBPeripheralDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
		guard self.peripheral == peripheral && error == nil else {
			NSLog("error discovering service: \(error)")
			self.cleanup()
			return
		}
		for service in peripheral.services ?? [] {
			peripheral.discoverCharacteristics([Bluetooth.Characteristics], forService: service)
		}
	}
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		guard self.peripheral == peripheral && error == nil else {
			NSLog("error discovering service: \(error)")
			self.cleanup()
			return
		}
		for characteristics in service.characteristics ?? [] {
			if characteristics.UUID == Bluetooth.Characteristics {
				self.peripheral!.setNotifyValue(true, forCharacteristic: characteristics)
			}
		}
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		guard self.peripheral == peripheral && error == nil else {
			NSLog("error discovering service: \(error)")
			self.cleanup()
			return
		}

		let string = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding)

		if string == Bluetooth.EOM {
			let string = String(data: self.data, encoding: NSUTF8StringEncoding)

			NSLog("\(string)")

			self.peripheral?.setNotifyValue(false, forCharacteristic: characteristic)
			self.manager.cancelPeripheralConnection(peripheral)
		}
		
		self.data.appendData(characteristic.value!)
	}
	
	func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
		if characteristic.UUID != Bluetooth.Characteristics {
			return
		}
		if characteristic.isNotifying {
			NSLog("notif begin on \(characteristic)")
		}
		else {
			self.manager.cancelPeripheralConnection(peripheral)
		}
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: cleanup
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func cleanup() {
		for service in (self.peripheral?.services)! {
			for characteristic in service.characteristics! {
				if characteristic.UUID == Bluetooth.Characteristics && characteristic.isNotifying {
					self.peripheral?.setNotifyValue(false, forCharacteristic: characteristic)
				}
			}
		}
		self.manager.cancelPeripheralConnection(self.peripheral!)
	}
	
	
}

