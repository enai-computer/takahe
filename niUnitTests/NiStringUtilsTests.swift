//
//  NiWebViewUtilsTests.swift
//  ni
//
//  Created by Patrick Lukas on 21/5/24.
//

import XCTest
import CoreSpotlight
import CoreLocation
@testable import Enai

final class NiStringUtilsTests: XCTestCase{
	
	func testURLfunctionality() throws{
		let url = try createWebUrl(from: "http://google.com/?query=http")
		print(url.baseURL?.absoluteString as Any)
		
		let url2 = URL(string: "https://drive.google.com/sadkjfn?nil=d&d=d")
		print(url2?.baseURL?.absoluteString as Any)
		XCTAssertTrue(true)
	}
	
	func testURLHost() throws{
		let url = URL(string: "https://mail.google.com/mail/u/0/#inbox")
		print(url?.host() as Any)
		
		let url2 = URL(string: "https://www.linear.app/")
		print(url2?.host() as Any)
	}
	
	func testSpotlightSearch() throws{
		let queryContext = CSUserQueryContext()
		queryContext.fetchAttributes = ["title", "textContent", "authorNames", "contentDescription"]
		queryContext.maxSuggestionCount = 10
		queryContext.enableRankedResults = true
		
		
		let query = CSUserQuery(userQueryString: "Hacking with macOS", userQueryContext: queryContext)
	
		Task{
			for try await r in query.responses{
				DispatchQueue.main.async {
					print(r)
				}
			}
		}
	}
	
	func testCLGeocoder() async throws{
		let geocoder = CLGeocoder()
		let locations = try await geocoder.geocodeAddressString("London") //("United States")
		for city in locations{
			print(city)
		}
	}
}
