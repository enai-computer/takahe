//
//  MaraeClient.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//
import Foundation
import Get

class MaraeClient{
	private let hostUrl = "http://127.0.0.1:8000"
	private let apiVersion = "/v1"
	private let userID = "/00000000-0000-0000-0000-000000000003"
	
	private let client: APIClient
	
	init(){
		client = APIClient(baseURL: URL(string: hostUrl))
	}
	
	func putRecord(record: OutboxMessage) async throws -> Bool{
		guard let url = URL(string: record.objectType.getRESTSubpath()) else{return false}
		let relPath = (apiVersion + userID + record.objectType.getRESTSubpath() + "/" + record.objectId.uuidString)
		
		var putRequest = Request(
			path: relPath,
			method: .put,
			body: record.message,
			headers: ["Content-Type": "application/json"]
		)
		
		let res = try await client.send(putRequest)
		if res.statusCode == 200{
			return true
		}
		return false
	}
}
