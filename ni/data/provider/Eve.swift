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
	
	func genWelcomeTxt(for name: String) async -> String?{
		guard PostHogSDK.shared.isFeatureEnabled("en-ai") else {return en_ai_disabled_response}
		do{
			return try await maraeClient.getWelcomeText(name)
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
