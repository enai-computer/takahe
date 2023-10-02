//Created on 30.09.23

import Cocoa
import WebKit

struct EnaiWebViewConstants {
    static let wvWidth: CGFloat = 900
    static let wvHeight: CGFloat = 400
    static let wvBoarderWidth: CGFloat = 10.0
    static let wvBoarderHeight: CGFloat = 10.0
    static let viewWidth: CGFloat = wvWidth + wvBoarderWidth * 2
    static let viewHeight: CGFloat = wvHeight + wvBoarderHeight * 2
    static let boarderColor = EnaiColors.SandLight3
    static let boarderColorSelected = EnaiColors.SandLight12
 }

class EnaiWebView3{

    
    var contentBox: NSBox? = nil
    init(_ searchTerm: String){
        contentBox = NSBox(frame: NSRect(x: 30, y: 30, width: EnaiWebViewConstants.viewWidth, height: EnaiWebViewConstants.viewHeight))
        contentBox!.title = searchTerm
        contentBox!.borderColor = EnaiWebViewConstants.boarderColor
        
        let wkView = WKWebView(frame: NSRect(x: 0, y: 0, width: EnaiWebViewConstants.wvWidth, height: EnaiWebViewConstants.wvHeight), configuration: WKWebViewConfiguration())
        let urlReq = URLRequest(url: URL(string: "https://www.google.com/search?q=" + searchTerm)!)
        
        wkView.load(urlReq)
               
        contentBox!.contentView?.addSubview(wkView)
        contentBox!.contentViewMargins = NSSize(width: EnaiWebViewConstants.wvBoarderWidth, height: EnaiWebViewConstants.wvBoarderHeight)
    }
    
    
}
