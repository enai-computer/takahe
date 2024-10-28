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
	
	func fetchIcon(_ urlStr: String) async -> NSImage? {
		guard let url = URL(string: urlStr) else { return nil }
		return await fetchIcon(url)
	}

	func fetchIcon(_ url: URL) async -> NSImage? {
		do{
			guard let host = url.host() else { return nil}
			if let cachedIcon = tryFetchFromCache(host){
				return cachedIcon
			}
			
			guard let icon = try await getFromWeb(url) else { return nil }
			cacheIcon(icon, domain: host)
			return icon
		} catch {
			print(error)
			return nil
		}
	}
	
	func fetchIcon(for contentId: UUID) async -> NSImage?{
		let cachedWebsite = CachedWebTable.fetchCachedWebsite(contentId: contentId)
		
		guard let url = cachedWebsite?.url else {return nil}
		return await fetchIcon(url)
	}
	
	func flushCache(){
		let favIconCache = Storage.instance.getDir(for: .favIcon)
		do{
			try FileManager.default.removeItem(at: favIconCache)
			try FileManager.default.createDirectory(at: favIconCache, withIntermediateDirectories: true, attributes: nil)
			FaviconCacheTable.flushTable()
		}catch{
			print("failed clearing cache with error: \(error)")
		}
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
		if(writePngToDisk(fUrl: fUrl, img: img)){
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
