//
//  NiWebViewUtils.swift
//  ni
//
//  Created by Patrick Lukas on 19/4/24.
//

import Foundation
import WebKit

func getEmtpyWebViewURL() -> URL{
	
	return Bundle.main.url(forResource: "emptyTab", withExtension: "html")!
}

func getCouldNotLoadWebViewURL() -> URL{
	return Bundle.main.url(forResource: "errorLoading", withExtension: "html")!
}

func generateWKWebViewConfiguration() -> WKWebViewConfiguration{
	let wvConfig = WKWebViewConfiguration()
//	wvConfig.mediaTypesRequiringUserActionForPlayback = .all
//	wvConfig.upgradeKnownHostsToHTTPS = true
	wvConfig.applicationNameForUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15"
	
	return wvConfig
}

