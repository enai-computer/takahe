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
	
	let maraeClient: MaraeClient
	
	init(){
		maraeClient = MaraeClient()
	}
	
	func ask(question: String) async -> String{
		PostHogSDK.shared.capture(
			"asked_en-ai",
			properties: ["ui-component": "palette"]
		)
		do{
			return try await maraeClient.askQuestion(question)
		}catch{
			print(error)
		}
		return "Failed to connect to the AI service."
	}
	
	func getWelcomeText(for spaceName: String) async -> String?{
		guard PostHogSDK.shared.isFeatureEnabled("en-ai") else {return en_ai_disabled_response}
		do{
			return try await maraeClient.getWelcomeText(spaceName)
		}catch{
			print(error)
		}
		return en_ai_disabled_response
	}
	
	func getInfoText(for spaceName: String, groupName: String? = nil, tabTitles: [String] = []) async -> String?{
		guard PostHogSDK.shared.isFeatureEnabled("en-ai") else {return en_ai_disabled_response}
		do{
			return try await maraeClient.getWelcomeText(
				WelcomeTextPayload(
					space_name: spaceName,
					group_name: groupName,
					context_tabs: tabTitles
				)
			)
		}catch{
			print(error)
		}
		return en_ai_disabled_response
	}

	private let en_ai_disabled_response = """
  <p>
	  In a few days, Enai will be the fastest way to chat with an AI. Thank you for your patience!
  </p>
"""
}
