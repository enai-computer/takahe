//
//  Eve.swift
//  ni
//
//  Created by Patrick Lukas on 28/9/24.
//

import Foundation
import PostHog

class Eve{
	static let instance = Eve()
	
	private let maraeClient: MaraeClient
	
	init(){
		maraeClient = MaraeClient()
	}
	
	func ask(question: String) async -> String{
		PostHogSDK.shared.capture(
			"asked_en-ai"
		)
		do{
			return try await maraeClient.askQuestion(question)
		}catch{
			print(error)
		}
		return "Failed to connect to the AI service."
	}
}
