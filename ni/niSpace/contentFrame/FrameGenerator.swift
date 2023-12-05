//Created on 02.10.23

import Cocoa
import WebKit

func runGoogleSearch(_ searchTerm: String, owner: Any?) -> ContentFrameView {
        
    let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let urlStr = "https://www.google.com/search?q=" + encodedSearchTerm!

    let frameController = ContentFrameController()
    frameController.loadView()
    frameController.openWebsiteInNewTab(urlStr)
    let frame = frameController.view as! ContentFrameView

    return frame
}

func openWebsiteInNewContentFrame(urlStr: String, initPosition: NSRect) -> ContentFrameView {
    
    let frameController = ContentFrameController()
    frameController.loadView()
    frameController.openWebsiteInNewTab(urlStr)
    
    let frame = frameController.view as! ContentFrameView
    frame.frame = initPosition
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
