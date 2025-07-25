//
//  MaraeClient.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//
import Foundation
import Get
import DeviceCheck
import PostHog

class MaraeClient{
	let hostUrl = "https://enai.host"
//	let hostUrl = "http://127.0.0.1:8000"
	private let apiVersion = "/v1"
	private let verify = "/verify"
	private let userID = "00000000-0000-0000-0000-000000000003"
	
	private let client: APIClient
	private let AUTH_HEADER_KEY = "Authorization"
	private var auth_header: [String: String] = [:]
	private var bearerToken: String = ""
	private var updatedAuthToken: Date?
	private var availableAiModels: [AiModel] = []
	private let minTimeBetweenAuth_sec: Double = -60.0
	
	init(){
		client = APIClient(baseURL: URL(string: hostUrl))
		verifyDevice()
	}
	
	func verifyDevice(callback: (()-> Void)? = nil){
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
					self.bearerToken = body.access_token
					self.auth_header = [self.AUTH_HEADER_KEY: "Bearer " + self.bearerToken]
					self.updatedAuthToken = .now
				}
				self.availableAiModels = try await self.getAvailableModels()
				callback?()
			}
		}
		return
	}
	
	func authKey() -> (String, String){
		let uId = PostHogSDK.shared.getDistinctId()
		return (uId, bearerToken)
	}
	
	func jsConformAiModels() -> NSArray{
		var res: [NSDictionary] = []
		for m in availableAiModels{
			res.append(m.toDictionary())
		}
		return NSArray(array: res)
	}
	
	func sendRecord(record: OutboxMessage) async throws -> Bool{
		let relPath = (apiVersion + "/" + userID + record.objectType.getRESTSubpath() + "/" + record.objectId.uuidString)
		
		let putRequest = Request(
			path: relPath,
			method: .put,
			body: record.message,
			headers: ["Content-Type": "application/json"]
		)
		return try await sendRequestNoResponse(putRequest)
	}
	
	func deleteRecord(record: OutboxMessage) async throws -> Bool{
		let relPath = (apiVersion + "/" + userID + record.objectType.getRESTSubpath() + "/" + record.objectId.uuidString)
		let delRequest = Request(
			path: relPath,
			method: .delete
		)
		return try await sendRequestNoResponse(delRequest)
	}
	
	func getVersion() async throws -> String{
		let req = Request(
			path: apiVersion + "/version",
			method: .get,
			headers: auth_header
		)
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			return String(data: res!.data, encoding: .utf8) ?? "failed to decode"
		}
		return "Failed to fetch version"
	}
	
	private func getAvailableModels() async throws -> [AiModel]{
		let relPath = apiVersion + "/" + userID + "/ai-models"
		let req = Request(
			path: relPath,
			method: .get,
			headers: auth_header
		)
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			let jsonD = JSONDecoder()
			let answer = try jsonD.decode(AiModelsResponse.self, from: res!.data)
			return answer.models
		}
		return []
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
		let relPath = apiVersion + "/" + userID + "/answer"
		let req = Request(
			path: relPath,
			method: .get,
			query: [
				("q", question.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
			],
			headers: auth_header
		)
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			let jsonD = JSONDecoder()
			let answer = try jsonD.decode(EveChatResponseMessage.self, from: res!.data)
			return answer.message
		}
		return "Failed to get answer to your question."
	}
	
	func getWelcomeText(_ spaceName: String) async throws -> String?{
		let relPath = apiVersion + "/" + userID + "/welcome-text"
		let req = Request(
			path: relPath,
			method: .get,
			query: [
				("sname", spaceName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
			],
			headers: [
				"Accept": "text/markdown",
				AUTH_HEADER_KEY: auth_header[AUTH_HEADER_KEY] ?? ""
			]
		)
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			let jsonD = JSONDecoder()
			let answer = try jsonD.decode(EveChatResponseMessage.self, from: res!.data)
			return answer.message
		}
		return nil
	}
	
	func getInfoText(_ body: WelcomeTextPayload) async throws -> String?{
		let relPath = apiVersion + "/" + userID + "/welcome-text"
		let req = Request(
			path: relPath,
			method: .post,
			body: body,
			headers: [
				"Content-Type": "application/json",
				AUTH_HEADER_KEY: auth_header[AUTH_HEADER_KEY] ?? ""
			]
		)
		let res = try await sendRequest(req)
		if(res?.statusCode == 200 && res != nil){
			let jsonD = JSONDecoder()
			let answer = try jsonD.decode(EveChatResponseMessage.self, from: res!.data)
			return answer.message
		}
		return nil
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
