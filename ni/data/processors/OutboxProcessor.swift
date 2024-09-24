//
//  OutboxProcessor.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//

import Foundation

class OutboxProcessor{
	
	private let client: MaraeClient
	
	init() {
		self.client = MaraeClient()
	}
	
	func run(){
		Task{
			await processRecordInTable()
		}
	}
	
	private func processRecordInTable() async{
		let record = OutboxTable.getFirstMessage()
		guard let (id, type, record) = record else {return}
		
		if(type == .PUT){
			do{
				let successful = try await client.putRecord(record: record)
				if(successful){
					OutboxTable.delete(id: id)
				}
			}catch{
				print(error)
			}
		}
	}
}
