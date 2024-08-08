//
//  NiDownloadHandler.swift
//  ni
//
//  Created by Patrick Lukas on 15/7/24.
//

import WebKit
import PDFKit
import Foundation

class NiDownloadHandler: NSObject, WKDownloadDelegate{

	static let instance = NiDownloadHandler()
	let downloadFolder: URL?
	var downloadsInProgress: [URLRequest: URL] = [:]
	var tabsToClose: Set<NiWebView> = []
	
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
		let source = download.originalRequest?.url?.absoluteString
		if let originalRequest: URLRequest = download.originalRequest{
			if let cachedDownloadLocation = downloadsInProgress[originalRequest]{
				Task{
					do{
						try handleDownloadedFile(in: cachedDownloadLocation, from: source)
					}catch{
						print(error)
					}
				}
			}
		}
		if let niWebView = download.webView as? NiWebView{
			if(tabsToClose.remove(niWebView) != nil){
				niWebView.owner?.closeTab(at: niWebView.tabHeadPosition)
			}
		}
	}
	
	func setCloseTabCallback(for niWV: NiWebView){
		tabsToClose.insert(niWV)
	}
	
	private func handleDownloadedFile(in cachedlocation: URL, from source: String?) throws{
		_ = downloadFolder?.startAccessingSecurityScopedResource()
		let title = cachedlocation.deletingPathExtension().lastPathComponent
		
		let destinationUrl = genDestUrl(
			destFileName: title,
			fileExtension: cachedlocation.pathExtension
		)
		if(cachedlocation.pathExtension == "pdf"){
			openPDF(from: cachedlocation, title: title, source: source)
		}
		try FileManager.default.moveItem(at: cachedlocation, to: destinationUrl)
		try FileManager.default.removeItem(at: cachedlocation.deletingLastPathComponent())
		downloadFolder?.stopAccessingSecurityScopedResource()
	}
	
	/** function to be called from a non-main thread. Opening will be dispatched to the main thread
	 
	 */
	private func openPDF(from path: URL, title: String, source: String?){
		if let pdf = PDFDocument(url: path){
			DispatchQueue.main.async {
				if let applicationDelegate = NSApplication.shared.delegate as? AppDelegate{
					if let spaceController = applicationDelegate.getNiSpaceViewController(){
						spaceController.pastePdf(pdf: pdf,
												 title: title,
												 source: source)
					}
				}
			}
		}
	}
	
	private func genDestUrl(destFileName: String, fileExtension: String) -> URL{
		let destPath: String = downloadFolder!.absoluteStringWithoutScheme!
		
		return genDestUrl(destPath: destPath,
						  destFileName: destFileName,
						  fileExtension: fileExtension,
						  iteration: 0)
	}
	
	private func genDestUrl(destPath: String, destFileName: String, fileExtension: String, iteration: Int) -> URL{
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
