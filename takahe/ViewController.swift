//Created on 11.09.23

import Cocoa
import WebKit


class ViewController: NSViewController {

    var wkView: WKWebView? = nil
    var webView: EnaiWebView3? = nil
    
    @IBAction func mainSearch(_ searchField: NSSearchField) {
        
        if( wkView == nil){
            wkView = WKWebView(frame: NSRect(x: 30, y: 30, width: 600, height: 300), configuration: WKWebViewConfiguration())
        }

        let searchTerm = searchField.stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let urlReq = URLRequest(url: URL(string: "https://www.google.com/search?q=" + searchTerm!)!)

        print(searchTerm!)
        wkView!.load(urlReq)

//        webView = EnaiWebView(searchTerm!)
        
        let window = NSApplication.shared.keyWindow
        window?.contentView?.addSubview(wkView!)
        window?.contentView?.addSubview((webView?.contentBox!)!)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.view.wantsLayer = true
        super.view.layer?.backgroundColor = EnaiColors.DefaultBackground // colorNamed("DefaultBackgroundColor")
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        (NSClassFromString("NSApplication")?.value(forKeyPath: "sharedApplication.windows") as? [AnyObject])?.first?.perform(#selector(NSWindow.toggleFullScreen(_:)))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

