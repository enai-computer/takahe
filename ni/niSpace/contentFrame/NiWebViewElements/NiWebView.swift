//
//  NiWebView.swift
//  ni
//
//  Created by Patrick Lukas on 12/5/23.
//

import Foundation
import Cocoa
import WebKit

class NiWebView: WKWebView{
    
    private let owner: ContentFrameController

    init(owner: ContentFrameController, frame: NSRect, configuration: WKWebViewConfiguration) {
        self.owner = owner
        
        super.init(frame: frame, configuration: configuration)
        GlobalScriptMessageHandler.instance.ensureHandles(configuration: self.configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
        
        // Hacky do nothing, if not a link
        if(menu.items[0].title == "Reload"){
            return
        }
        
        // if menuItem.identifier?.rawValue == "WKMenuItemIdentifierOpenLink" {
        let niOpenInNewTab = NSMenuItem()
        
        niOpenInNewTab.title = "open link in new tab"
        niOpenInNewTab.action = #selector(openLinkInNewTab(_:))
        niOpenInNewTab.target = self
        menu.items = [niOpenInNewTab]
    
    }
    
    @objc func openLinkInNewTab(_ sender: AnyObject) {
            if let url = GlobalScriptMessageHandler.instance.contextMenu_href {
                owner.openWebsiteInNewTab(url)
            }
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
    
    static private var WHOLE_PAGE_SCRIPT = """
        window.oncontextmenu = (event) => {
            var target = event.target

            var href = target.href
            var parentElement = target
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
                href
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
        }
    }
}
