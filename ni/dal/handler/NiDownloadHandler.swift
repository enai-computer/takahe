//
//  NiDownloadHandler.swift
//  ni
//
//  Created by Patrick Lukas on 15/7/24.
//

import WebKit
import Foundation

class NiDownloadHandler: NSObject, WKDownloadDelegate{

	static let instance = NiDownloadHandler()
	let downloadFolder: URL?
	var downloadsInProgress: [URLRequest: URL] = [:]
	
	override init() {
		do {
			 downloadFolder = try FileManager.default.url(
				for: FileManager.SearchPathDirectory.downloadsDirectory,
				in: FileManager.SearchPathDomainMask.userDomainMask,
				appropriateFor: nil,
				create: true)
		} catch{
			  print(error)
			downloadFolder = nil
		}
	}

	func download(_ download: WKDownload, 
				  decideDestinationUsing response: URLResponse,
				  suggestedFilename: String,
				  completionHandler: @escaping (URL?) -> Void) {
		let destinationUrl = Storage.instance.genFileUrl(for: UUID(), ofType: .partialDownload, with: suggestedFilename)
		do{
			try FileManager.default.createDirectory(at: destinationUrl.deletingLastPathComponent(), withIntermediateDirectories: false)
		}catch{
			completionHandler(nil)
			return
		}
		
		completionHandler(destinationUrl)
		if let originalRequest: URLRequest = download.originalRequest{
			downloadsInProgress[originalRequest] = destinationUrl
		}
	}
	
	func downloadDidFinish(_ download: WKDownload) {
		if let originalRequest: URLRequest = download.originalRequest{
			if let cachedDownloadLocation = downloadsInProgress[originalRequest]{
				do{
					let gotAccess = downloadFolder?.startAccessingSecurityScopedResource()

					let destinationUrl = genDestUrl(
						destPath: downloadFolder!.absoluteStringWithoutScheme!,
						destFileName: cachedDownloadLocation.deletingPathExtension().lastPathComponent,
						fileExtension: cachedDownloadLocation.pathExtension
					)
					try FileManager.default.moveItem(at: cachedDownloadLocation, to: destinationUrl)
					try FileManager.default.removeItem(at: cachedDownloadLocation.deletingLastPathComponent())
					downloadFolder?.stopAccessingSecurityScopedResource()
				}catch{
					print(error)
				}
			}
		}
	}
	
	private func genDestUrl(destPath: String, destFileName: String, fileExtension: String, iteration: Int = 0) -> URL{
		let filePath: String
		
		if(iteration == 0){
			filePath = destPath + destFileName + "." + fileExtension
		}else{
			filePath = destPath + destFileName + " (\(iteration))." + fileExtension
		}
		
		if(FileManager.default.fileExists(atPath: filePath)){
			return genDestUrl(destPath: destPath, destFileName: destFileName, fileExtension: fileExtension, iteration: iteration + 1)
		}
		return URL(fileURLWithPath: filePath)
	}
	
	// Check permission is granted or not
	public func hasAccessToDownloadsFolder() -> Bool {
		let hasAccess = downloadFolder?.startAccessingSecurityScopedResource() ?? false
		downloadFolder?.stopAccessingSecurityScopedResource()
		return hasAccess
	}
}
