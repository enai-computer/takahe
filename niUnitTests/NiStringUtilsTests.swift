//
//  NiWebViewUtilsTests.swift
//  ni
//
//  Created by Patrick Lukas on 21/5/24.
//

import XCTest
@testable import ni

final class NiStringUtilsTests: XCTestCase{
	
	func testCreateWebUrl() throws{
		let url = try createWebUrl(from: "http://google.com")
		XCTAssertTrue(url.scheme == "https")
	}
	
}
