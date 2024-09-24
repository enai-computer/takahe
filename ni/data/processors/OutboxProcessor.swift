//
//  OutboxProcessor.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//

import Foundation

class OutboxProcessor{
	
	struct FailedSendCounter{
		var count: Int = 0
		var triedLast: Date?
	}
	
	private let client: MaraeClient
	private var failedSendCounter: FailedSendCounter
	
	init() {
		self.client = MaraeClient()
		self.failedSendCounter = FailedSendCounter()
	}
	
	func run(){
		guard UserSettings.shared.onlineSync else {return}
		Task{
			while( await processRecordInTable() ) {}
		}
	}
	
	private func processRecordInTable() async -> Bool{
		guard allowSending() else {return false}
		
		let record = OutboxTable.getNextMessage()
		guard let (id, type, record) = record else {return false}
		
		if(type == .PUT){
			do{
				let successful = try await client.sendRecord(record: record)
				if(successful){
					succeededSending(message: id)
				}else{
					failedSending(message: id)
				}
			}catch{
				print(error)
				failedSending(message: id)
			}
		}else if(type == .DELETE){
			do{
				if(try await client.deleteRecord(record: record)){
					succeededSending(message: id)
				}else{
					failedSending(message: id)
				}
			}catch{
				print(error)
				failedSending(message: id)
			}
		}else{
			//killing the potential for an endless loop of an undefined object
			OutboxTable.delete(id: id)
		}
		return true
	}
	
	private func allowSending() -> Bool{
		//TODO: tech debt,- needs to be cleaned up. Find a good library implementation
		if(5 < failedSendCounter.count){
			return false
		}
		return true
	}
	
	private func succeededSending(message id: UUID){
		OutboxTable.delete(id: id)
		
		failedSendCounter.count = 0
		failedSendCounter.triedLast = nil
	}
	
	private func failedSending(message id: UUID){
		OutboxTable.increaseFailureCount(for: id)
		failedSendCounter.count += 1
		failedSendCounter.triedLast = Date.now
	}
}
