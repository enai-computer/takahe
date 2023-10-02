//Created on 02.10.23

import Cocoa
import WebKit

func runGoogleSearch(_ searchTerm: String) -> NSView {
    
    let wkView = WKWebView(frame: NSRect(x: 30, y: 30, width: 600, height: 300), configuration: WKWebViewConfiguration())
    
    let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    
    let urlReq = URLRequest(url: URL(string: "https://www.google.com/search?q=" + encodedSearchTerm!)!)
    print(searchTerm)
    wkView.load(urlReq)
    
    let frame = ContentFrameView(contentHeader: searchTerm, content: wkView)
    
    return frame
}
