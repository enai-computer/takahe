//
//  WebsiteIconProvider.swift
//  ni
//
//  Created by Patrick Lukas on 30/5/24.
//

import Cocoa
import FaviconFinder

class FaviconProvider{
	
	static let instance = FaviconProvider()
	private init(){}
	
	func fetchIcon(_ urlStr: String) async -> NSImage?{
		
		
		do{
			let url = URL(string: urlStr)!
			return try await getFromWeb(url)
		}catch{
			print(error)
		}
		return nil
	}
	
	private func getFromWeb(_ url: URL) async throws -> NSImage?{
		return try await FaviconFinder(url: url)
				.fetchFaviconURLs()
				.download()
				.largest().image?.image
	}
}
