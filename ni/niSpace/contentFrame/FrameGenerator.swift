//Created on 02.10.23

import Cocoa
import WebKit

func runGoogleSearch(_ searchTerm: String, owner: Any?) -> ContentFrameView {
    
    let wkView = WKWebView(frame: NSRect(x: 30, y: 30, width: 900, height: 360), configuration: WKWebViewConfiguration())
    
    let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    
    let urlStr = "https://www.google.com/search?q=" + encodedSearchTerm!
    let urlReq = URLRequest(url: URL(string: urlStr)!)
    print(searchTerm)
    wkView.load(urlReq)
    
//    let niFrame: ContentFrameView = NSView.loadFromNib(nibName: "ContentFrameView", owner: owner)! as! ContentFrameView
    let frameController = ContentFrameController()
    frameController.loadView()
    let frame = frameController.view as! ContentFrameView
    frame.contentHeader.stringValue = urlStr
    frame.setContent(wkView)

    return frame
}

func openWebsite(_ urlStr: String, owner: Any?) -> ContentFrameView {
    
    let wkView = WKWebView(frame: NSRect(x: 30, y: 30, width: 900, height: 400), configuration: WKWebViewConfiguration())
    
    let urlReq = URLRequest(url: URL(string: urlStr)!)

    wkView.load(urlReq)
    
//    let frame: ContentFrameView = NSView.loadFromNib(nibName: "ContentFrameView", owner: owner)! as! ContentFrameView
    let frameController = ContentFrameController()
    frameController.loadView()
    let frame = frameController.view as! ContentFrameView
    frame.contentHeader.stringValue = urlStr
    frame.setContent(wkView)

    return frame
}

func openWebsite(urlStr: String, owner: Any?, width: NiCoordinate, height: NiCoordinate, position: NiViewPosition) -> ContentFrameView{
    
    let wkView = WKWebView(frame: NSRect(x: position.x.px, y: position.y.px, width: width.px, height: height.px), configuration: WKWebViewConfiguration())
    
    let urlReq = URLRequest(url: URL(string: urlStr)!)
    wkView.load(urlReq)
    
//    let frame: ContentFrameView = NSView.loadFromNib(nibName: "ContentFrameView", owner: owner)! as! ContentFrameView
    let frameController = ContentFrameController()
    frameController.loadView()
    let frame = frameController.view as! ContentFrameView
    frame.contentHeader.stringValue = urlStr
    frame.setContent(wkView)
    
    return frame
}

extension NSView {

    static func loadFromNib(nibName: String, owner: Any?) -> NSView? {

        var arrayWithObjects: NSArray?

        let nibLoaded = Bundle.main.loadNibNamed(NSNib.Name(nibName), owner: owner, topLevelObjects: &arrayWithObjects)

        if nibLoaded {
            guard let unwrappedObjectArray = arrayWithObjects else { return nil }
            for object in unwrappedObjectArray {
                if object is NSView {
                    return object as? NSView
                }
            }
            return nil
        } else {
            return nil
        }
    }
}
