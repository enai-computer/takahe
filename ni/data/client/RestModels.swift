//
//  RestTypes.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//
import Foundation

enum RestObjectType: String{
	case webContent, note, pdf
	
	func getRESTSubpath() -> String{
		switch(self){
			case .webContent:
				return "/webContent"
			case .note:
				return "/note"
			case .pdf:
				return "/pdf"
		}
		
	}
}

enum RestEventType: String{
	case PUT, DELETE
}

struct OutboxMessage{
	let objectId: UUID
	let objectType: RestObjectType
	let message: String
}

struct NoteMessage: Codable{
	let spaceId: UUID
	let title: String?
	let content: String
	let updatedAt: Double
}

struct WebContentMessage: Codable{
	let spaceId: UUID
	let title: String?
	let url: String
	let updatedAt: Double
}

struct PdfMetadataMesssage: Codable{
	let spaceId: UUID
	let title: String?
	let url: String
	let updatedAt: Double
}

struct EveChatResponseMessage: Codable{
	let message: String
}

struct MaraeVerifyResponse: Codable{
	let access_token: String
	let token_type: String
}

struct AiModel: Codable{
	let id: String
	let name: String
	let description: String
	
	func toDictionary() -> NSDictionary {
		return NSDictionary(dictionaryLiteral: ("id", id), ("name", name), ("description", description))
	}
}

struct AiModelsResponse: Codable{
	let models: [AiModel]
}

struct WelcomeTextPayload: Codable{
	let space_name: String
	let group_name: String?
	let context_tabs: [String]
}
