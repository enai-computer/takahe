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
			guard let host = url.host() else { return nil}
			if let cachedIcon = tryFetchFromCache(host){
				return cachedIcon
			}
			
			if let icon = try await getFromWeb(url){
				cacheIcon(icon, domain: host)
				return icon
			}
		}catch{
			print(error)
		}
		return nil
	}
	
	private func tryFetchFromCache(_ host: String) -> NSImage? {
		if let storageLocation = FaviconCacheTable.fetchIconLocation(domain: host){
			if let fUrl = URL(string: storageLocation){
				if let cachedIcon = fetchImgFromDisk(fUrl){
					return cachedIcon
				}
			}
		}
		return nil
	}
	
	private func cacheIcon(_ img: NSImage, domain: String){
		let fUrl = Storage.instance.genFileUrl(for: UUID(), ofType: .favIcon)
		if(writeImgToDisk(fUrl: fUrl, img: img)){
			FaviconCacheTable.upsert(domain: domain, storageLocation: fUrl.absoluteString)
		}
	}
	
	private func getFromWeb(_ url: URL) async throws -> NSImage?{
		return try await FaviconFinder(url: url)
				.fetchFaviconURLs()
				.download()
				.largest().image?.image
	}
}
