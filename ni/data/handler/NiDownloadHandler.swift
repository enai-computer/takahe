//
//  NiDownloadHandler.swift
//  ni
//
//  Created by Patrick Lukas on 15/7/24.
//

@preconcurrency import WebKit
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
		
		if let niWebView = download.webView as? NiWebView{
			let confirmationView = loadConfirmationView(with: "download started", into: niWebView.frame.size)
			niWebView.addSubview(confirmationView)
		}
	}
	
	func downloadDidFinish(_ download: WKDownload) {
		let source = download.originalRequest?.url?.absoluteString
		if let originalRequest: URLRequest = download.originalRequest{
			if let cachedDownloadLocation = downloadsInProgress[originalRequest]{
				Task{
					do{
						try handleDownloadedFile(in: cachedDownloadLocation, from: source)
						visualDownloadFeedback(for: download.webView, successful: true)
					}catch{
						print(error)
						visualDownloadFeedback(for: download.webView, successful: false)
					}
				}
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
	
	private func visualDownloadFeedback(for webView: WKWebView?, successful: Bool){
		if let niWebView = webView as? NiWebView{
			if(successful){
				let confirmationView = loadConfirmationView(with: "also saved to Mac 'Downloads'", into: niWebView.frame.size, durationOnScreen: 8.0)
				niWebView.addSubview(confirmationView)
				niWebView.layoutSubtreeIfNeeded()
				positionConfirmationViewOnScreen(view: confirmationView, enclosingFrame: niWebView.frame.size)
			}else{
				let confirmationView = loadConfirmationView(with: "failed to download file", into: niWebView.frame.size, durationOnScreen: 8.0)
				niWebView.addSubview(confirmationView)
				niWebView.layoutSubtreeIfNeeded()
				positionConfirmationViewOnScreen(view: confirmationView, enclosingFrame: niWebView.frame.size)
			}
			if(tabsToClose.remove(niWebView) != nil){
				niWebView.owner?.closeTab(at: niWebView.tabHeadPosition)
			}
		}
	}
	
	private func loadConfirmationView(with message: String, into frame: CGSize, durationOnScreen: CGFloat = 4.0) -> NSView{

		let confirmationView = (NSView.loadFromNib(nibName: "CFSoftDeletedView", owner: self) as! CFSoftDeletedView)
		confirmationView.initAfterViewLoad(
			message: message,
			showUndoButton: false,
			animationTime_S: durationOnScreen,
			borderWidth: 2.0,
			borderColor: .birkinT70,
			borderDisappears: true
		)
		
		positionConfirmationViewOnScreen(view: confirmationView, enclosingFrame: frame)
		
		return confirmationView
	}
	
	private func positionConfirmationViewOnScreen(view: NSView, enclosingFrame: CGSize){
		let margin = 20.0
		view.frame.origin = CGPoint(
			x: enclosingFrame.width - margin - view.frame.width,
			y: 0 + margin
		)
	}
	
	// Check permission is granted or not
	public func hasAccessToDownloadsFolder() -> Bool {
		let hasAccess = downloadFolder?.startAccessingSecurityScopedResource() ?? false
		downloadFolder?.stopAccessingSecurityScopedResource()
		return hasAccess
	}
}
