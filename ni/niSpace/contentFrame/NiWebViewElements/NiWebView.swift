//
//  NiWebView.swift
//  ni
//
//  Created by Patrick Lukas on 12/5/23.
//

import Foundation
import Cocoa
import Carbon.HIToolbox
import WebKit
import PDFKit
import PostHog

class NiWebView: WKWebView, CFContentItem, CFContentSearch{
    
    weak var owner: ContentFrameController?
    private(set) var viewIsActive: Bool = true
	var tabHeadPosition: Int = -1
	var retries: Int = 0
	let findConfig = WKFindConfiguration()
	private(set) var websiteLoaded = false
	private var eveHandler: EveChatHandler?
	private var popUp: NiPopUpViewController? = nil
	
	// overlays own view to deactivate clicks and visualise deactivation state
	private var overlay: NSView?
	var searchPanel: NiWebViewFindPanel?
	var prevFindAvailable: Bool = true
	var nextFindAvailable: Bool = true
	
	private var zoomLevel: Int = 7
	private var titleChangeObserver: NSKeyValueObservation?
	private var canGobackObserver: NSKeyValueObservation?
	private var canGoForwardObserver: NSKeyValueObservation?
	
    init(owner: ContentFrameController, frame: NSRect) {
        self.owner = owner
		let wvConfig = generateWKWebViewConfiguration()
        
        super.init(frame: frame, configuration: wvConfig)
        GlobalScriptMessageHandler.instance.ensureHandles(configuration: self.configuration)
		eveHandler = EveChatHandler(self)
		eveHandler?.ensureHandles(configuration: self.configuration)
		
		findConfig.caseSensitive = false
		findConfig.wraps = false
		
		self.allowsBackForwardNavigationGestures = true
		self.allowsLinkPreview = true
		
		titleChangeObserver = self.observe(
			\.title,
			 options: [.new]
		){niWebView, val in
			niWebView.titleChanged()
		}
		
		canGobackObserver = self.observe(
			\.canGoBack,
			 options: [.initial, .new]
		){ niWebView, change in
			niWebView.owner?.niWebViewCanGoBack(change.newValue ?? false, niWebView)
		}
		canGoForwardObserver = self.observe(
			\.canGoForward,
			 options: [.initial, .new]
		){ niWebView, change in
			niWebView.owner?.niWebViewCanGoFwd(change.newValue ?? false, niWebView)
		}
    }
	
	init(frame: NSRect) {
		let wvConfig = generateWKWebViewConfiguration()
		super.init(frame: frame, configuration: wvConfig)
		GlobalScriptMessageHandler.instance.ensureHandles(configuration: self.configuration)
		eveHandler = EveChatHandler(self)
		eveHandler?.ensureHandles(configuration: self.configuration)
		
		findConfig.caseSensitive = false
		findConfig.wraps = false
		self.allowsBackForwardNavigationGestures = true
		self.allowsLinkPreview = true
	}
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        
        // Hacky do nothing, if not a link
        if(menu.items[0].title != "Open Link"){
			replaceSearchWithGoogleAction(menu)
            return
        }
		
        // if menuItem.identifier?.rawValue == "WKMenuItemIdentifierOpenLink" {
        let niOpenInNewTab = NSMenuItem()
        
        niOpenInNewTab.title = "open link in new tab"
        niOpenInNewTab.action = #selector(openLinkInNewTab(_:))
        niOpenInNewTab.target = self
        menu.items = [niOpenInNewTab]
    }
	
	@IBAction override func printView(_ sender: Any?){
		return
	}

	func viewLoadedWebsite(){
		websiteLoaded = true
	}
	
	func spaceClosed(){
		self.pauseAllMediaPlayback()
		self.closeAllMediaPresentations { } // Avoiding `await`ing the new API.
		self.stopLoading()
	}

	func spaceRemovedFromMemory(){
		self.pauseAllMediaPlayback()
		self.closeAllMediaPresentations { } // Avoiding `await`ing the new API.
		self.navigationDelegate = nil
		self.uiDelegate = nil
		self.owner = nil
		self.searchPanel = nil
		self.overlay = nil
		self.stopLoading()
	}
	
	func getCurrentURL() -> String? {
		if let urlStr = url?.absoluteString as? String{
			return urlStr
		}
		return nil
	}
	
	func getTitle() -> String?{
		if(title == "/"){
			return nil
		}
		if(title != nil && !title!.isEmpty){
			return title!
		}
		if let fileName = url?.pathComponents.last{
			return fileName
		}
		return nil
	}
	
	private func replaceSearchWithGoogleAction(_ menu: NSMenu){
		for item in menu.items{
			if(item.title == "Search with Google"){
				item.action = #selector(runGoogleSearch(_:))
				item.target = self
			}
		}
	}
	
	//function for right click open link in new tab
    @objc func openLinkInNewTab(_ sender: AnyObject) {
		if let url = GlobalScriptMessageHandler.instance.contextMenu_href {
			owner?.openWebsiteInNewTab(url, shallSelectTab: false, openNextToSelectedTab: true)
		}
	}
	
	
	//function for right click - search google
	@objc func runGoogleSearch(_ sender: AnyObject) {
		if let selectedText = GlobalScriptMessageHandler.instance.contextMenu_selectedText {
			let url = searchUrl(from: selectedText)
			owner?.openWebsiteInNewTab(url)
		}
	}
    
    func setActive(){
		overlay?.removeFromSuperview()
		overlay = nil
        viewIsActive = true
    }
    
	@discardableResult
	func setInactive() -> FollowOnAction{
		if(owner == nil){return .nothing}
		overlay = cfOverlay(frame: self.frame, nxtResponder: owner!.view)
		addSubview(overlay!)
		window?.makeFirstResponder(overlay)
		viewIsActive = false
		return .nothing
	}
	
	override func keyDown(with event: NSEvent) {
		if(viewIsActive && event.modifierFlags.contains(.command) && event.keyCode == kVK_ANSI_R){
			self.reload()
			return
		}

		if(viewIsActive 
		   && event.modifierFlags.isDisjoint(with: EventUtils.ModifierFlagsWithoutFunction)
		   && (
			event.keyCode == kVK_LeftArrow
			|| event.keyCode == kVK_RightArrow
			|| event.keyCode == kVK_UpArrow
			|| event.keyCode == kVK_DownArrow
		   )){
			return
		}
		super.keyDown(with: event)
	}
	
	override func cancelOperation(_ sender: Any?) {
		return
	}
	

	@IBAction func zoomIn(_ sender: NSMenuItem) {
		(zoomLevel, self.pageZoom) = NiZoomLevels.zoomIn(zoomLevel)
	}
	
	@IBAction func zoomOut(_ sender: NSMenuItem) {
		(zoomLevel, self.pageZoom) = NiZoomLevels.zoomOut(zoomLevel)
	}
	
	@IBAction func zoomReset(_ sender: NSMenuItem) {
		(zoomLevel, self.pageZoom) = NiZoomLevels.defaultZoomLevel()
	}
	
	@IBAction func performFindPanelAction(_ sender: NSMenuItem) {
		guard searchPanel == nil else{return}
		
		//needs to be ordered this way, otherwise the action images will be null in setNiWebView
		searchPanel = NiWebViewFindPanel()
		addSubview(searchPanel!.view)
		searchPanel!.setParentViewItem(self)
	}
	
	@IBAction func performFindNext(_ sender: NSMenuItem){
		performFindNext()
	}
	
	func performFindNext() {
		guard searchPanel != nil else {return}
		performFind(searchPanel!.searchField.stringValue, backwards: false)
	}
	
	@IBAction func performFindPrevious(_ sender: NSMenuItem){
		performFindPrevious()
	}
	
	func performFindPrevious() {
		guard searchPanel != nil else {return}
		performFind(searchPanel!.searchField.stringValue, backwards: true)
	}
	
	private func performFind(_ search: String, backwards: Bool){
		findConfig.backwards = backwards
		self.find(search, configuration: findConfig, completionHandler: handleFindResults)
	}
	
	func handleFindResults(_ result: WKFindResult){
		//setting opposite direction button true or false depending if results are available
		if(result.matchFound){
			if(findConfig.backwards){
				nextFindAvailable = true
				searchPanel?.nxtFindButton.tintActive()
			}else{
				prevFindAvailable = true
				searchPanel?.prevFindButton.tintActive()
			}
		}else{
			if(findConfig.backwards){
				prevFindAvailable = false
				searchPanel?.prevFindButton.tintInactive()
			}else{
				nextFindAvailable = false
				searchPanel?.nxtFindButton.tintInactive()
			}
		}
	}
	
	func resetSearchAvailability(){
		prevFindAvailable = true
		nextFindAvailable = true
	}
	
	func titleChanged(){
		if (isEveChatURL() && title == "Blank page"){return}
		owner?.niWebViewTitleChanged(self)
	}
	
	//MARK: handle pop-ups
	func displayUpPop(configuration: WKWebViewConfiguration,
					 windowFeatures: WKWindowFeatures
	) -> NiWebPopUp? {
		guard popUp == nil else {return nil}
		popUp = NiPopUpViewController(with: configuration)
		positionAndSize(popUpView: popUp!.view, windowFeatures: windowFeatures)
		self.addSubview(popUp!.view)
		return popUp?.niWebView
	}
	
	private func positionAndSize(
		popUpView: NSView,
		windowFeatures: WKWindowFeatures
	){
		let margin = 20.0
		
		if let targetSize = getNSSizeFrom(width: windowFeatures.width, height: windowFeatures.height){
			popUpView.frame.size = targetSize
		}else{
			popUpView.frame.size = CGSize(width: 500.0, height: 400.0)
		}
		
		popUpView.frame.size = maxSize(enclosingFrameSize: bounds.size, subFrame: popUpView.frame.size, margin: margin)

		popUpView.frame.origin = centeredFrameOrigin(enclosingRect: bounds, subFrame: popUpView.frame.size, margin: margin)
	}
	
	//MARK: - Eve AI handler
	func passEnaiAPIAuth(){
		guard PostHogSDK.shared.isFeatureEnabled("en-ai") else {return}
		guard isEveChatURL() else {return}
		let (userId, bearerToken) = Eve.instance.maraeClient.authKey()
		self.evaluateJavaScript("API_BASE_HOST = \"\(Eve.instance.maraeClient.hostUrl)\""){
			(result, error) in
			print(error as Any)
		}
		self.evaluateJavaScript("updateAuthDetails({userId: \"\(userId)\", bearerToken: \"\(bearerToken)\"});"){
		   (result, error) in
		   print(error as Any)
	   }
	}
	
	func passEnaiAPIAuthOnMain(){
		DispatchQueue.main.async {
			self.passEnaiAPIAuth()
		}
	}
	
	func passRefreshedEnaiAPIAuth(){
		guard PostHogSDK.shared.isFeatureEnabled("en-ai") else {return}
		guard isEveChatURL() else {return}
		Eve.instance.maraeClient.verifyDevice(callback: self.passEnaiAPIAuthOnMain)
	}
	
	func setWelcomeMessage(_ message: String){
		guard isEveChatURL() else {return}
		let messDic: [[String:String]] = [["role": "assistant", "content": message]]
		Task{
			do{
				try await self.callAsyncJavaScript("setMessages(data);",
					 arguments: ["data": messDic],
					 contentWorld: WKContentWorld.page
				)
			}catch{
				print(error)
			}
		}
	}
	
	func fetchEveMessages() async -> String?{
		guard isEveChatURL() else {return nil}
		do{
			let dic = try await self.evaluateJavaScript("getMessages()")
			let jsonData: Data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
			return String(data: jsonData, encoding: .utf8)
		}catch{
			print(error)
		}
		return nil
	}
	
	func setEveMessageHistory(){
		guard isEveChatURL() else {return}
		guard let contentId = owner?.safeGetTab(at: tabHeadPosition)?.contentId else {return}
		guard let messageData = EveChatTable.fetchMessageHistory(contentId: contentId)?.data(using: .utf8) else {return}
		Task{
			do{
				if let storedChatTitle: String = ContentTable.fetchURLTitleSource(for: contentId)?.1 {
					try await self.callAsyncJavaScript("document.title = data;",
													   arguments: ["data": storedChatTitle],
													   contentWorld: WKContentWorld.page
					)
					DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) {
						//execution delayed, as this otherwise get's called before contentframe controller is drawn
						self.titleChanged()
					}
				}
				let messDic = try JSONSerialization.jsonObject(with: messageData)
				try await self.callAsyncJavaScript("setMessages(data);",
					 arguments: ["data": messDic],
					 contentWorld: WKContentWorld.page
				)
			}catch{
				print(error)
			}
		}
	}
	
	func isEveChatURL() -> Bool{
		return self.url == getEmtpyWebViewURL()
	}
	
	//MARK: - Deinit
	deinit{
		canGobackObserver?.invalidate()
		canGoForwardObserver?.invalidate()
		titleChangeObserver?.invalidate()
		
		overlay?.removeFromSuperview()
		overlay = nil
		eveHandler = nil
		popUp?.view.removeFromSuperview()
		popUp?.removeFromParent()
		popUp = nil
		
		stopLoading()
	}
}

class GlobalScriptMessageHandler: NSObject, WKScriptMessageHandler {
    /**
     *  copied from here: https://stackoverflow.com/a/66836354
     */
    public private(set) static var instance = GlobalScriptMessageHandler()
    
    public private(set) var contextMenu_nodeName: String?
    public private(set) var contextMenu_nodeId: String?
    public private(set) var contextMenu_hrefNodeName: String?
    public private(set) var contextMenu_hrefNodeId: String?
    public private(set) var contextMenu_href: String?
	public private(set) var contextMenu_selectedText: String?
    
    static private var WHOLE_PAGE_SCRIPT = """
        window.oncontextmenu = (event) => {
            var target = event.target

            var href = target.href
            var parentElement = target
            var selectedText = window.getSelection().toString()
            while (href == null && parentElement.parentElement != null) {
                parentElement = parentElement.parentElement
                href = parentElement.href
            }

            if (href == null) {
                parentElement = null;
            }

            window.webkit.messageHandlers.oncontextmenu.postMessage({
                nodeName: target.nodeName,
                id: target.id,
                hrefNodeName: parentElement?.nodeName,
                hrefId: parentElement?.id,
                href,
                selectedText
            });
        }
        """
    
    private override init() {
        super.init()
    }
    
    public func ensureHandles(configuration: WKWebViewConfiguration) {
        
        var alreadyHandling = false
        for userScript in configuration.userContentController.userScripts {
            if userScript.source == GlobalScriptMessageHandler.WHOLE_PAGE_SCRIPT {
                alreadyHandling = true
            }
        }
        
        if !alreadyHandling {
            let userContentController = configuration.userContentController
            userContentController.add(self, name: "oncontextmenu")
            
            let userScript = WKUserScript(source: GlobalScriptMessageHandler.WHOLE_PAGE_SCRIPT, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            userContentController.addUserScript(userScript)
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let body = message.body as? NSDictionary {
			contextMenu_nodeName = body["nodeName"] as? String
			contextMenu_nodeId = body["id"] as? String
			contextMenu_hrefNodeName = body["hrefNodeName"] as? String
			contextMenu_hrefNodeId = body["hrefId"] as? String
			contextMenu_href = body["href"] as? String
			contextMenu_selectedText = body["selectedText"] as? String
        }
    }
}

class EveChatHandler: NSObject, WKScriptMessageHandlerWithReply {
	private weak var niWebView: NiWebView?
	
	init(_ webView: NiWebView) {
		self.niWebView = webView
		super.init()
	}
	
	public func ensureHandles(configuration: WKWebViewConfiguration) {
		let userContentController = configuration.userContentController
		userContentController.addScriptMessageHandler(
			self,
			contentWorld: WKContentWorld.page,
			name: "en_ai_handler"
		)
	}
	
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) async -> (Any?, String?) {
		guard let body = message.body as? NSDictionary else {return (nil, nil)}
		guard body["source"] as? String == "enai-agent" else{return (nil, nil)}
		if let type = body["type"] as? String{
			if(type == "request-history"){
				niWebView?.setEveMessageHistory()
			}else if(type == "token-request"){
				niWebView?.passRefreshedEnaiAPIAuth()
			}
		}
		return (nil, nil)
	}
	
	
}
