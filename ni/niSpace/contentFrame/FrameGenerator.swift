//Created on 02.10.23

import Cocoa
import WebKit

let maxWidthMargin: CGFloat = 30.0

func openEmptyContentFrame(viewState: NiConentFrameState = .expanded) -> ContentFrameController{
	let frameController = ContentFrameController(viewState: viewState, tabsModel: nil)
	frameController.loadView()
	return frameController
}

func reopenContentFrame(screenWidth: CGFloat, contentFrame: NiContentFrameModel, tabDataModel: [NiCFTabModel]) -> ContentFrameController{
	let tabViewModels = niCFTabModelToTabViewModel(tabs: tabDataModel)
	let controller = reopenContentFrameWithOutPositioning(
		screenWidth: screenWidth,
		contentFrameState: contentFrame.state,
		tabViewModels: tabViewModels
	)
	//positioning
	controller.view.frame = initPositionAndSize(
		maxWidth: (screenWidth - maxWidthMargin),
		contentFrame: contentFrame
	)
	return controller
}

func reopenContentFrameWithOutPositioning(screenWidth: CGFloat, contentFrameState: NiConentFrameState, tabViewModels: [TabViewModel]) -> ContentFrameController {
    
	var activeTab: Int = -1
	
	let frameController = if(contentFrameState == .minimised){
		ContentFrameController(viewState: contentFrameState, tabsModel: tabViewModels)
	}else{
		// we are not adding tabViewModel here as opening up a tab down there does that.
		//FIXME: clean up that tech debt
		ContentFrameController(viewState: contentFrameState)
	}

    frameController.loadView()
	
	if(contentFrameState == .minimised){
		return frameController
	}
	
	//loading tabs
	//TODO: refactor,- set TabModel and let the content controllerreopen the tabs
	for (i, tab) in tabViewModels.enumerated(){

		if(tab.state == .empty ){
			_ = frameController.openEmptyWebTab(tab.contentId)
		}else{
			_ = frameController.openWebsiteInNewTab(urlStr: tab.url, contentId: tab.contentId, tabName: tab.title, webContentState: tab.state)
		}
		
		//Clean-up after 1st of July 2024,-
		//existing users have all their tabs active by default
		//once all users updated to 0.1.4 Build 7 or later and opened and stored all spaces at least once
		if(tab.isSelected){
			activeTab = i
		}
    }
	if(0 <= activeTab){
		frameController.forceSelectTab(at: activeTab)
	}
	
    return frameController
}

/** Resizing here, in case the CFs are out of bounds on reload on a smaller screen
 
 */
func initPositionAndSize(maxWidth: CGFloat, contentFrame: NiContentFrameModel) -> NSRect {
	var width = contentFrame.width.px
	var x = contentFrame.position.x.px

	if(maxWidth < width){
		width = maxWidth
	}
	
	//in the minimized State we want CFs to be fully on screen
	if(contentFrame.state == .minimised){
		let maxX = maxWidth - width
		if(maxX < x){
			x = maxX
		}
	}else{ //otherwise min Exposure must be visible
		let maxX = maxWidth - minContentFrameExposure
		if(maxX < x){
			x = maxX
		}
	}
	
	return NSRect(
		origin: CGPoint(x: x, y: contentFrame.position.y.px),
		size: CGSize(width: width, height: contentFrame.height.px)
	)
}

func niCFTabModelToTabViewModel(tabs: [NiCFTabModel]) -> [TabViewModel]{
	var activeTabSet: Bool = false
	var tabPositionCorrectionNeeded = false
	var tabViews: [TabViewModel] = []
	
	for tabModel in tabs {
		let record = CachedWebTable.fetchCachedWebsite(contentId: tabModel.id)
		var tabView = TabViewModel(contentId: tabModel.id, type: .web, title: record.title, url: record.url, position: tabModel.position)
		
		if(tabModel.position < 0 || tabs.count <= tabModel.position){
			tabPositionCorrectionNeeded = true
		}
		
		if(tabModel.active && !activeTabSet){
			tabView.isSelected = true
			activeTabSet = true
		}else{
			tabView.isSelected = false
		}
		tabView.state = TabViewModelState(rawValue: tabModel.contentState)!

		tabViews.append(tabView)
	}
	
	if(tabPositionCorrectionNeeded){
		for (i, tViewModel) in tabViews.enumerated(){
			tabViews[i].position = i
		}
	}
	
	return tabViews
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
