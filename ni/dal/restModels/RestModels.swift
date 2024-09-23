//
//  RestTypes.swift
//  ni
//
//  Created by Patrick Lukas on 23/9/24.
//
import Foundation

enum RestObjectType: String{
	case webContent, note, pdf
}

enum RestEventType: String{
	case PUT, DELETE
}

struct OutboxMessage{
	let objectId: UUID
	let objectType: RestObjectType
	let message: String
}
