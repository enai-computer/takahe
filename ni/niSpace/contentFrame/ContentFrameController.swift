//
//  ContentFrameController.swift
//  ni
//
//  Created by Patrick Lukas on 12/3/23.
//

import Foundation
import Cocoa
import WebKit

class ContentFrameController: NSViewController, WKNavigationDelegate, NSTableViewDataSource, NSTableViewDelegate{
    
    var niContentFrameView: ContentFrameView? = nil
    var tabHeaders: [NiCFTabHeaderView] = []
    
    override func loadView() {
        self.niContentFrameView = (NSView.loadFromNib(nibName: "ContentFrameView", owner: self) as! ContentFrameView)
        self.view = niContentFrameView!
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor(.sandLight1).cgColor
    }
    
    private func getNewWebView(contentId: UUID, tabHeader: NiCFTabHeaderView, urlReq: URLRequest, frame: NSRect) -> NiWebView {

        let wkView = NiWebView(contentId: contentId, tabHeader: tabHeader, owner: self, frame: frame, configuration: WKWebViewConfiguration())
        wkView.load(urlReq)
        wkView.navigationDelegate = self
        return wkView
    }
    
    func openWebsiteInNewTab(urlStr: String, contentId: UUID){
        let urlReq = URLRequest(url: URL(string: urlStr)!)
        let tabHead = NiCFTabHeaderView()
        tabHead.setContentFrameView(niContentFrameView: self.niContentFrameView!)
        
        let niWebView = getNewWebView(contentId: contentId, tabHeader: tabHead, urlReq: urlReq, frame: niContentFrameView!.frame)
        niWebView.navigationDelegate = self
        
        tabHead.tabPosition = niContentFrameView!.createNewTab(tabView: niWebView, label: "", urlStr: urlStr)
        
        tabHeaders.insert(tabHead, at: tabHead.tabPosition)
        
        let tabHeaderTableColumn = NSTableColumn()
        tabHeaderTableColumn.title = String(tabHead.tabPosition)
        niContentFrameView?.niTabHeaderView.addTableColumn(tabHeaderTableColumn)
    }
    
    func openWebsiteInNewTab(_ urlStr: String){
        let id = UUID()
        openWebsiteInNewTab(urlStr: urlStr, contentId: id)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let title = webView.title?.truncate(20)
        if title!.isEmpty{
            return
        }
        let niWV = webView as! NiWebView
        
        niWV.tabHeader.setTitle(title: title!)
    }
    
    //MARK: - provding ni View Tabs
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
  
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?{
        let pos = Int(tableColumn!.title)
        
        return tabHeaders[pos!]
    }
    
}


class NiCFTabHeaderView: NSView{
    
    var tabPosition = -1
    private var niContentFrameView: ContentFrameView?
    
    func setContentFrameView(niContentFrameView: ContentFrameView){
        self.niContentFrameView = niContentFrameView
    }
    
    func setTitle(title: String){
        let label = NSTextField(labelWithString: title)
        self.addSubview(label)
    }
    
    override func mouseDown(with event: NSEvent) {
        if (event.clickCount == 1){
            niContentFrameView!.selectTab(pos: tabPosition)
        }
    }
}
