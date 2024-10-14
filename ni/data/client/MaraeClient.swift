//
//  MaraeClient.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//
import Foundation
import Get
import DeviceCheck

class MaraeClient{
//	private let hostUrl = "https://enai.host"
	private let hostUrl = "http://127.0.0.1:8000"
	private let apiVersion = "/v1"
	private let verify = "/verify"
	private let userID = "/00000000-0000-0000-0000-000000000003"
	
	private let client: APIClient
	private let AUTH_HEADER_KEY = "Authorization"
	private var auth_header: [String: String] = [:]
	private var updatedAuthToken: Date?
	private let minTimeBetweenAuth_sec: Double = -60.0
	
	init(){
		client = APIClient(baseURL: URL(string: hostUrl))
		verifyDevice()
	}
	
	func verifyDevice(){
		let relPath = (apiVersion + verify)

		getDeviceToken { deviceToken in
			let getRequest = Request(
				path: relPath,
				method: .get,
				headers: ["Apple-Device-Token": deviceToken ?? ""]
			)

			Task{
				let res = try await self.client.send(getRequest)
				if(res.statusCode == 200){
					let jsonD = JSONDecoder()
					let body = try jsonD.decode(MaraeVerifyResponse.self, from: res.data)
					self.auth_header = [self.AUTH_HEADER_KEY: "Bearer " + body.access_token]
					self.updatedAuthToken = .now
				}
			}
		}
		return
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
	
	func getVersion() async throws -> String{
		let req = Request(
			path: "/version",
			method: .get,
			headers: auth_header
		)
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			return String(data: res!.data, encoding: .utf8) ?? "failed to decode"
		}
		return "Failed to fetch status"
	}
	
	func testStatus() async throws -> String{
		let req = Request(
			path: "/status",
			method: .get,
			headers: auth_header
		)
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			return String(data: res!.data, encoding: .utf8) ?? "failed to decode"
		}
		return "Failed to fetch status"
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
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			let jsonD = JSONDecoder()
			let answer = try jsonD.decode(EveChatResponseMessage.self, from: res!.data)
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
	
	private func sendRequest(_ req: Request<()>) async throws -> Response<Void>?{
		do{
			let res = try await client.send(req)
			return res
		}catch{
			if let errorCode = (error as? APIError)?.errorCode as? Int{
				if(errorCode == 401 && (updatedAuthToken == nil || updatedAuthToken!.timeIntervalSinceNow < minTimeBetweenAuth_sec)){
					verifyDevice()
					try await Task.sleep(for: .seconds(3))
					var reqUpdatedHeader = req
					reqUpdatedHeader.headers?.removeValue(forKey: AUTH_HEADER_KEY)
					reqUpdatedHeader.headers?[AUTH_HEADER_KEY] = auth_header[AUTH_HEADER_KEY]
					return try await sendRequest(reqUpdatedHeader)
				}
			}
			print(error)
		}
		return nil
	}
	
	private func getDeviceToken(completion: @escaping (String?) -> ()) {
		let currentDevice = DCDevice.current
		guard currentDevice.isSupported else { print("Device is not supported");return}
			
		currentDevice.generateToken{ (data, error) in
			guard let tokenData = data else {print("Error generating token: \(error!.localizedDescription)"); return}
			let tokenString = tokenData.base64EncodedString()
			print("Received device token")
			completion(tokenString)
		}
	}
}

extension APIError{
	public var errorCode: Int? {
		switch self {
		case .unacceptableStatusCode(let statusCode):
				return statusCode
		}
	}
}
