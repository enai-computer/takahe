//
//  CFC+WKDelegates.swift
//  Enai
//
//  Created by Patrick Lukas on 9/12/24.
//

@preconcurrency import WebKit
import Cocoa

/*
 * MARK: - WKDelegate navigation functions
 */
extension ContentFrameController:  WKNavigationDelegate{
	
	func webView(_ webView: WKWebView, didFinish: WKNavigation!){
		if(!viewHasTabs()){
			if(0 < tabs.count){
				tabs[0].state = .loaded
			}
			return
		}
		guard let wv = webView as? NiWebView else{return}
		wv.viewLoadedWebsite()
		
		if(wv.tabHeadPosition == -1){
			wv.tabHeadPosition = 0
		}
		//check if tab was closed by the time this callback happens
		if(tabs.count <= wv.tabHeadPosition || tabs[wv.tabHeadPosition].webView != wv){
			return
		}
		
		wv.retries = 0
		
		self.tabs[wv.tabHeadPosition].title = wv.getTitle() ?? tabs[wv.tabHeadPosition].title
		self.tabs[wv.tabHeadPosition].icon = nil
		
		//an empty tab still loads a local html
		if(self.tabs[wv.tabHeadPosition].state != .empty &&
		   self.tabs[wv.tabHeadPosition].state != .error &&
		   self.tabs[wv.tabHeadPosition].type != .eveChat
		){
			self.tabs[wv.tabHeadPosition].state = .loaded
			if(wv.url != nil){
				self.tabs[wv.tabHeadPosition].content = wv.url!.absoluteString
			}
			guard !tabs[wv.tabHeadPosition].inEditingMode else {return}
			if let nrOfItems: Int = viewWithTabs?.cfTabHeadCollection?.numberOfItems(inSection: 0){
				if(wv.tabHeadPosition < nrOfItems){
					viewWithTabs?.cfTabHeadCollection?.reloadItems(
						at: Set(arrayLiteral: IndexPath(item: wv.tabHeadPosition, section: 0))
					)
				}
			}
		}
		
		if(self.tabs[wv.tabHeadPosition].state == .loaded){
			let webTab: TabViewModel = self.tabs[wv.tabHeadPosition]
			
			Task{
				try await Task.sleep(for: .seconds(5))
				if let content: String = await wv.fetchWebcontent(){
					DocumentDal.upsertExtractedContent(conentId: webTab.contentId, type: .web, title: webTab.title, content: content)
				}
			}
		}
	}

	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView, with: error)
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView, with: error)
	}

	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		
		if(navigationAction.shouldPerformDownload){
			decisionHandler(.download)
			return
		}
		if let contentType = navigationAction.request.value(forHTTPHeaderField: "Content-Type"){
			if(contentType == "application/pdf"){
				decisionHandler(.download)
				return
			}
		}
		
		guard let urlStr: String = navigationAction.request.url?.absoluteString else {
			decisionHandler(.allow)
			return
		}
		
		//turning view into one with tabs
		if(viewState == .simpleFrame && !urlStr.isEmpty && navigationAction.modifierFlags.contains(.command)){
			simpleFrameToExpanded()
		}
		
		//open in new tab, comand clicked on link
		if(navigationAction.modifierFlags.contains(.command) && viewHasTabs()){
			if(!urlStr.isEmpty){
				self.openWebsiteInNewTab(urlStr, shallSelectTab: false, openNextToSelectedTab: true)
				decisionHandler(.cancel)
				return
			}
		}
		decisionHandler(.allow)
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
		if navigationAction.shouldPerformDownload {
			decisionHandler(.download, preferences)
			return
		}
		
		if let contentType = navigationAction.request.value(forHTTPHeaderField: "Content-Type"){
			if(contentType == "application/pdf"){
				decisionHandler(.download, preferences)
				return
			}
		}
		guard let urlStr: String = navigationAction.request.url?.absoluteString else {
			decisionHandler(.allow, preferences)
			return
		}
		
		//turning view into one with tabs
		if(viewState == .simpleFrame && !urlStr.isEmpty && navigationAction.modifierFlags.contains(.command)){
			simpleFrameToExpanded()
		}
		
		//open in new tab, comand clicked on link
		if(navigationAction.modifierFlags.contains(.command) && viewHasTabs()){
			if(!urlStr.isEmpty){
				self.openWebsiteInNewTab(urlStr, shallSelectTab: false, openNextToSelectedTab: true)
				decisionHandler(.cancel, preferences)
				return
			}
		}
		decisionHandler(.allow, preferences)
	}
	
	//1301 - decidePolicyFor navigationResponse
	func webView(_ webView: WKWebView,
				 decidePolicyFor navigationResponse: WKNavigationResponse,
				 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
	) {
		if (navigationResponse.response.mimeType == "application/pdf"){
			decisionHandler(.download)
			if let niWV = webView as? NiWebView{
				if(!niWV.websiteLoaded && viewHasTabs()){
					NiDownloadHandler.instance.setCloseTabCallback(for: niWV)
				}
			}
			return
		}
		if navigationResponse.canShowMIMEType {
			decisionHandler(.allow) // In case of force download file; decisionHandler(.download)
			return
		}
		decisionHandler(.download)
	}

	func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload){
		download.delegate = NiDownloadHandler.instance
	}
	
	func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload){
		download.delegate = NiDownloadHandler.instance
	}
	
	func webViewDidClose(_ webView: WKWebView){
		guard viewHasTabs() else {return}
		if let niWebView = webView as? NiWebView{
			closeTab(at: niWebView.tabHeadPosition)
		}
	}
	
	func webViewWebContentProcessDidTerminate(_ webView: WKWebView){
		let url = webView.url ?? getCouldNotLoadWebViewURL()
		guard let niWebView = webView as? NiWebView else {return}
		let replacementWebView = getNewWebView(owner: self, urlReq: URLRequest(url: url), frame: webView.frame)
		
		if viewState.hasTabs(){
			guard viewWithTabs?.swapView(newView: replacementWebView, at: niWebView.tabHeadPosition) == true else {return}
			niWebView.spaceRemovedFromMemory()
			if (niWebView.tabHeadPosition < tabs.count && 0 <= niWebView.tabHeadPosition){
				tabs[niWebView.tabHeadPosition].repalaceViewItem(with: replacementWebView)
			}
		}else if(viewState == .simpleFrame){
			guard let simpleFrameView = simpleFrame else {return}
			simpleFrameView.swapView(oldView: niWebView, with: replacementWebView)
			niWebView.spaceRemovedFromMemory()
			if(0 < tabs.count){
				tabs[0].repalaceViewItem(with: replacementWebView)
			}
		}else{
			assertionFailure("Please support webViewWebContentProcessDidTerminate(_ webView: WKWebView) for type \(viewState.rawValue)")
		}
	}
	
	//MARK: Enai specific functions
	func niWebViewTitleChanged(_ webView: NiWebView){
		guard viewIsDrawn else {return}
		
		if(viewState == .simpleFrame){
			simpleFrame?.cfGroupButton.setView(title: webView.getTitle())
			return
		}
		guard viewHasTabs() else {return}
		
		if(0 <= webView.tabHeadPosition && webView.tabHeadPosition < tabs.count){
			guard !tabs[webView.tabHeadPosition].inEditingMode else {return}
			self.tabs[webView.tabHeadPosition].title = webView.getTitle() ?? tabs[webView.tabHeadPosition].title
			if let nrOfItems: Int = viewWithTabs?.cfTabHeadCollection?.numberOfItems(inSection: 0){
				if(webView.tabHeadPosition < nrOfItems){
					guard let tabHead = viewWithTabs?.cfTabHeadCollection?.item(at: webView.tabHeadPosition) as? ContentFrameTabHead else {return}
					tabHead.updateTitle(newTitle: self.tabs[webView.tabHeadPosition].title)
				}
			}
		}
	}
	
	func niWebViewCanGoBack(_ newValue: Bool, _ webView: NiWebView){
		guard let fwdBackView: CFFwdBackButtonProtocol = view as? CFFwdBackButtonProtocol else {return}
		fwdBackView.setBackButtonTint(newValue, trigger: webView)
	}
	
	func niWebViewCanGoFwd(_ newValue: Bool, _ webView: NiWebView){
		guard let fwdBackView: CFFwdBackButtonProtocol = view as? CFFwdBackButtonProtocol else {return}
		fwdBackView.setForwardButtonTint(newValue, trigger: webView)
	}
	
	private func handleFailedLoad(_ webView: WKWebView, with error: any Error){
		if error._domain == "WebKitErrorDomain" && error._code == 102{
			return
		}
		guard let wv = webView as? NiWebView else{
			let errorURL = getCouldNotLoadWebViewURL()
			webView.loadFileURL(errorURL, allowingReadAccessTo: errorURL.deletingLastPathComponent())
			return
		}
		if let retryUrl = error._userInfo?["NSErrorFailingURLStringKey"] as? String{
			if (wv.retries < 2 && wv.load(retryUrl)){
				wv.retries += 1
				return
			}
		}

		let errorURL = getCouldNotLoadWebViewURL()
		webView.loadFileURL(errorURL, allowingReadAccessTo: errorURL.deletingLastPathComponent())

		if let errorMessage = (error._userInfo?["NSLocalizedDescription"] as? String){
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				replaceText(errorMessage)
			}
		}
		
		func replaceText(_ errorMessage: String) {
			let jsCode = "updateErrorMessage('\(errorMessage)');"
			webView.evaluateJavaScript(jsCode) { result, error in
				if let error = error {
					print("Error executing JavaScript: \(error.localizedDescription)")
				}
			}
		}
		
		guard viewHasTabs() else {return}
		self.tabs[wv.tabHeadPosition].state = .error
	}
}

/*
 * MARK: - WKUIDelegate UI functions
 */
extension ContentFrameController: WKUIDelegate{
	func webView(_ webView: WKWebView,
				 createWebViewWith configuration: WKWebViewConfiguration,
				 for navigationAction: WKNavigationAction,
				 windowFeatures: WKWindowFeatures
	) -> WKWebView?{
		
		if(navigationAction.navigationType == .reload){
			webView.reload()
		}
		
		guard let urlStr: String = navigationAction.request.url?.absoluteString else {
			return nil
		}
		if(viewState == .simpleFrame && !urlStr.isEmpty && navigationAction.targetFrame == nil){
			simpleFrameToExpanded()
		}
		guard viewHasTabs() else {return nil}
		
		if(navigationAction.targetFrame == nil && !urlStr.isEmpty){
			//open in new tab, example clicked file in gDrive
			if(navigationAction.navigationType == .linkActivated){
				self.openWebsiteInNewTab(urlStr, openNextToSelectedTab: true)
				return nil
			}
			//cmd + click twitter
			if((windowFeatures.height == nil && windowFeatures.x == nil) || navigationAction.modifierFlags.contains(.command)){
				self.openWebsiteInNewTab(urlStr, openNextToSelectedTab: true)
				return nil
			}
			//open pop-up for SSO for example
			if(navigationAction.navigationType == .other){
				//see example code here: https://stackoverflow.com/questions/52987509/xcode-wkwebview-code-to-allow-webview-to-process-popups
				if let niWebView = webView as? NiWebView{
					return niWebView.displayUpPop(
						configuration: configuration,
						windowFeatures: windowFeatures
					)
				}
			}
		}
		return nil
	}

	func webView(
		_ webView: WKWebView,
		runOpenPanelWith parameters: WKOpenPanelParameters,
		initiatedByFrame frame: WKFrameInfo,
		completionHandler: @escaping @MainActor ([URL]?) -> Void
	){
		let filePicker = genSystemFilePicker()
		filePicker.begin{ response in
			if response == .OK {
			   let pickedFolders = filePicker.urls
				completionHandler(pickedFolders)
			}else{
				completionHandler(nil)
			}
		}
	}
	
}
