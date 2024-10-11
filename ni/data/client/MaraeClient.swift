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
	
	func sendRecord(record: OutboxMessage) async throws -> Bool{
		let relPath = (apiVersion + userID + record.objectType.getRESTSubpath() + "/" + record.objectId.uuidString)
		
		let putRequest = Request(
			path: relPath,
			method: .put,
			body: record.message,
			headers: ["Content-Type": "application/json"]
		)
		return try await sendRequestNoResponse(putRequest)
	}
	
	func deleteRecord(record: OutboxMessage) async throws -> Bool{
		let relPath = (apiVersion + userID + record.objectType.getRESTSubpath() + "/" + record.objectId.uuidString)
		let delRequest = Request(
			path: relPath,
			method: .delete
		)
		return try await sendRequestNoResponse(delRequest)
	}
	
	func askQuestion(_ question: String) async throws -> String{
		let relPath = apiVersion + userID + "/answer"
		let req = Request(
			path: relPath,
			method: .get,
			query: [
				("q", question.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
			]
		)
		let res = try await client.send(req)
		if(res.statusCode == 200){
			let jsonD = JSONDecoder()
			let answer = try jsonD.decode(EveChatResponseMessage.self, from: res.data)
			return answer.message
		}
		return "Failed to get answer to your question."
	}
	
	func askWebsite(_ question: String, websites: [String]) async throws -> String{
		let jsonE = JSONEncoder()
		let context = try jsonE.encode(
			MaraeAskWebsiteRequestMessage(
				prevMessage: [],
				webContext: websites
			)
		)
		
		let relPath = apiVersion + userID + "/answer"
		let req = Request(
			path: relPath,
			method: .post,
			query: [
				("q", question.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
			],
			body: String(data: context, encoding: .utf8) ?? ""
		)
		let res = try await client.send(req)
		if(res.statusCode == 200){
			let jsonD = JSONDecoder()
			let answer = try jsonD.decode(EveChatResponseMessage.self, from: res.data)
			return answer.message
		}
		return "Failed to get answer to your question."
	}

	private func sendRequestNoResponse(_ req: Request<()>) async throws -> Bool{
		let res = try await client.send(req)
		if res.statusCode == 200{
			return true
		}
		return false
	}
}
