//Created on 11.09.23

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBAction func mainSearch(_ searchTerm: NSSearchField) {
        //TODO: open webview with google search
        let wv = WKWebView()
//        let urlString: String =
//        let url_ = URL(string: "https://www.google.com/search?q=" + searchTerm.stringValue)
        let urlReq = URLRequest(url: URL(string: "https://www.google.com/search?q=" + searchTerm.stringValue)!)
        wv.load(urlReq)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

