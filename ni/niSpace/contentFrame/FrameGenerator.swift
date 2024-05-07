//Created on 02.10.23

import Cocoa
import WebKit

func openEmptyContentFrame() -> ContentFrameController{
	let frameController = ContentFrameController(viewState: .expanded)
	frameController.loadView()
	
	return frameController
}

func reopenContentFrame(contentFrame: NiContentFrameModel, tabs: [NiCFTabModel]) -> ContentFrameController {
    
	var activeTab: Int = -1
	let frameController = ContentFrameController(viewState: contentFrame.state)
    frameController.loadView()
	for (i, tab) in tabs.enumerated(){
        let record = CachedWebTable.fetchCachedWebsite(contentId: tab.id)
		if(WebViewState(rawValue: tab.contentState) == .empty ){
			_ = frameController.openEmptyTab(tab.id)
		}else{
			_ = frameController.openWebsiteInNewTab(urlStr: record.url, contentId: tab.id, tabName: record.title, webContentState: tab.contentState)
		}
		
		//Clean-up after 1st of July 2024,-
		//existing users have all their tabs active by default
		//once all users updated to 0.1.4 Build 7 or later and opened and stored all spaces at least once
		if(tab.active){
			activeTab = i
		}
    }
    
    //positioning
    let initPosition = NSRect(
        origin: CGPoint(x: contentFrame.position.x.px, y: contentFrame.position.y.px),
        size: CGSize(width: contentFrame.width.px, height: contentFrame.height.px)
    )

	frameController.view.frame = initPosition
	if(0 <= activeTab){
		frameController.forceSelectTab(at: activeTab)
	}
	
    return frameController
}

//openEmptyTab WebViewState(rawValue: webContentState!)!

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
