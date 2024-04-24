//Created on 02.10.23

import Cocoa
import WebKit

func openEmptyContentFrame() -> ContentFrameController{
	let frameController = ContentFrameController()
	frameController.loadView()
	
	return frameController
}

func reopenContentFrame(contentFrame: NiContentFrameModel, tabs: [NiCFTabModel]) -> ContentFrameController {
    
    let frameController = ContentFrameController()
    frameController.loadView()
    for tab in tabs{
        let record = CachedWebTable.fetchCachedWebsite(contentId: tab.id)
		_ = frameController.openWebsiteInNewTab(urlStr: record.url, contentId: tab.id, tabName: record.title, webContentState: tab.contentState)
    }
    
    //positioning
    let initPosition = NSRect(
        origin: CGPoint(x: contentFrame.position.x.px, y: contentFrame.position.y.px),
        size: CGSize(width: contentFrame.width.px, height: contentFrame.height.px)
    )

	frameController.view.frame = initPosition
    
    return frameController
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
