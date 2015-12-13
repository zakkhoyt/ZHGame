//
//  BluetoothClient.swift
//  CoreBluetooth
//
//  Created by Tibor Bodecs on 2015. 10. 15..
//  Copyright © 2015. Tibor Bodecs. All rights reserved.
//

import Foundation
import CoreBluetooth


class BluetoothClient: NSObject, CBPeripheralManagerDelegate
{

	var peripheralManager : CBPeripheralManager!
	var transferCharacteristic : CBMutableCharacteristic?
	var data = NSMutableData()
	var sendDataIndex : NSInteger = 0
	var sendingEOM = false


	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: init
	///////////////////////////////////////////////////////////////////////////////////////////////////

	static let sharedInstance = BluetoothClient()

	private override init() {
		super.init()

		self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: advertising API
	///////////////////////////////////////////////////////////////////////////////////////////////////

	func stopAdvertising() {
		self.peripheralManager.stopAdvertising()
	}

	func startAdvertising() {
		self.peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [Bluetooth.Service]])
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////
	//  MARK: CBPeripheralManagerDelegate
	///////////////////////////////////////////////////////////////////////////////////////////////////
	
	func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
		guard peripheral.state == .PoweredOn else {
			return NSLog("peripherial is not powered on")
		}

		self.transferCharacteristic = CBMutableCharacteristic(type: Bluetooth.Characteristics, properties: .Notify, value: nil, permissions: .Readable)
		
		let service = CBMutableService(type: Bluetooth.Service, primary: true)

		service.characteristics = [self.transferCharacteristic!]

		self.peripheralManager.addService(service)
		
		NSLog("service added")

		self.startAdvertising()
	}
	
	func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
		NSLog("central subscribed to characteristic")
		
		self.data			= "lorem ipsum".dataUsingEncoding(NSUTF8StringEncoding)?.mutableCopy() as! NSMutableData
		self.sendDataIndex	= 0
		self.sendingEOM		= false

		self.sendData()
	}

	func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
		self.sendData()
	}

	func sendData() {
		if self.sendingEOM {
			let didSend = self.peripheralManager.updateValue(Bluetooth.EOMData, forCharacteristic: self.transferCharacteristic!, onSubscribedCentrals: nil)
			if didSend {
				self.sendingEOM = false
			}
			return
		}

		if self.sendDataIndex >= self.data.length {
			return //no data left
		}
		
		var didSend = true
		
		while didSend {
			var amountToSend = self.data.length - self.sendDataIndex
			
			if amountToSend > 20 {
				amountToSend = 20
			}
			let chunk = NSData(bytes: self.data.bytes+self.sendDataIndex, length: amountToSend)
			didSend = self.peripheralManager.updateValue(chunk, forCharacteristic: self.transferCharacteristic!, onSubscribedCentrals: nil)
			
			if !didSend {
				return
			}
			let sentData = String(data: chunk, encoding: NSUTF8StringEncoding)

			NSLog("\(sentData)")
			
			self.sendDataIndex += amountToSend

			if self.sendDataIndex >= self.data.length {
				self.sendingEOM = true
				let didSend     = self.peripheralManager.updateValue(Bluetooth.EOMData, forCharacteristic: self.transferCharacteristic!, onSubscribedCentrals: nil)
				if didSend {
					self.sendingEOM = false
				}
				return
			}
		}
	}

}

