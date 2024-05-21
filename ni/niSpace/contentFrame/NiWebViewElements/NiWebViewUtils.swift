//
//  NiWebViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 19/4/24.
//

import Foundation
import WebKit


func getNewWebView(owner: ContentFrameController, contentId: UUID, urlReq: URLRequest, frame: NSRect) -> NiWebView {
	let wkView = NiWebView(contentId: contentId, owner: owner, frame: frame)
	wkView.load(urlReq)
	wkView.navigationDelegate = owner
	wkView.uiDelegate = owner
	
	return wkView
}

func getNewWebView(owner: ContentFrameController, contentId: UUID, frame: NSRect, fileUrl: URL? = nil) -> NiWebView {
	let niWebView = NiWebView(contentId: contentId, owner: owner, frame: frame)
	niWebView.uiDelegate = owner
	
	let localHTMLurl = if(fileUrl == nil) {
		getEmtpyWebViewURL()
	}else{
		fileUrl!
	}
	niWebView.loadFileURL(localHTMLurl, allowingReadAccessTo: localHTMLurl)
	niWebView.navigationDelegate = owner
	return niWebView
}

func getNewWebView(owner: ContentFrameController, frame: NSRect, dirtyUrl: String, contentId: UUID) -> NiWebView{
	let url: URL
	do{
		url = try createWebUrl(from: dirtyUrl)
	}catch{
		url = getCouldNotLoadWebViewURL()
	}

	let urlReq = URLRequest(url: url)
	
	return getNewWebView(owner: owner, contentId: contentId, urlReq: urlReq, frame: frame)
}

func getNewWebView(owner: ContentFrameController, frame: NSRect, cleanUrl: String, contentId: UUID) -> NiWebView{
	let url = URL(string: cleanUrl)
	if(url == nil){
		return getNewWebView(owner: owner, frame: frame, dirtyUrl: cleanUrl, contentId: contentId)
	}
	if(url!.scheme!.hasPrefix("file")){
		return getNewWebView(owner: owner, contentId: contentId, frame: frame, fileUrl: url)
	}
	let urlReq = URLRequest(url: url!)
	return ni.getNewWebView(owner: owner, contentId: contentId, urlReq: urlReq, frame: frame)
}

func getEmtpyWebViewURL() -> URL{
	return Bundle.main.url(forResource: "emptyTab", withExtension: "html")!
}

func getCouldNotLoadWebViewURL() -> URL{
	return Bundle.main.url(forResource: "errorLoading", withExtension: "html")!
}

func generateWKWebViewConfiguration() -> WKWebViewConfiguration{
	let wvConfig = WKWebViewConfiguration()
//	wvConfig.mediaTypesRequiringUserActionForPlayback = .all
	wvConfig.upgradeKnownHostsToHTTPS = true
	wvConfig.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15"
	return wvConfig
}

