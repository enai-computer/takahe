//
//  NiWebViewUtilsTests.swift
//  ni
//
//  Created by Patrick Lukas on 21/5/24.
//

import XCTest
@testable import ni

final class NiStringUtilsTests: XCTestCase{
	
	func testURLfunctionality() throws{
		let url = try createWebUrl(from: "http://google.com/?query=http")
		print(url.baseURL?.absoluteString)
		
		let url2 = URL(string: "https://drive.google.com/sadkjfn?nil=d&d=d")
		print(url2?.baseURL?.absoluteString)
		XCTAssertTrue(true)
	}
	
	func testIsValidWebUrl(){
		XCTAssertTrue(isValidWebUrl(url: "x.com"))
	}
	
}
