//
//  Eve.swift
//  ni
//
//  Created by Patrick Lukas on 28/9/24.
//

import Foundation

class Eve{
	static let instance = Eve()
	
	private let maraeClient: MaraeClient
	
	init(){
		maraeClient = MaraeClient()
	}
	
	func ask(question: String) async -> String{
		do{
			return try await maraeClient.askQuestion(question)
		}catch{
			print(error)
		}
		return ""
	}
}
