//Created on 02.10.23

import Cocoa
import WebKit

let maxWidthMargin: CGFloat = 30.0

func openEmptyContentFrame(viewState: NiConentFrameState = .expanded) -> ContentFrameController{
	let frameController = ContentFrameController(viewState: viewState, groupName: nil, tabsModel: nil)
	frameController.loadView()
	return frameController
}

func reopenContentFrame(screenWidth: CGFloat, contentFrame: NiContentFrameModel, tabDataModel: [NiCFTabModel]) -> ContentFrameController{
	let tabViewModels = niCFTabModelToTabViewModel(tabs: tabDataModel)
	let controller = reopenContentFrameWithOutPositioning(
		screenWidth: screenWidth,
		contentFrameState: contentFrame.state,
		tabViewModels: tabViewModels,
		groupName: contentFrame.name
	)
	//positioning
	controller.view.frame = initPositionAndSize(
		maxWidth: (screenWidth - maxWidthMargin),
		contentFrame: contentFrame
	)
	
	if(controller.tabs.count != tabViewModels.count){
		preconditionFailure("Tabs not generated correctly. Contentframe is missing tabs")
	}
	
	return controller
}

func reopenContentFrameWithOutPositioning(
	screenWidth: CGFloat,
	contentFrameState: NiConentFrameState,
	tabViewModels: [TabViewModel],
	groupName: String?
) -> ContentFrameController {
    
	let frameController = if(contentFrameState == .minimised){
		ContentFrameController(viewState: contentFrameState,
							   groupName: groupName,
							   tabsModel: tabViewModels)
	}else{
		// we are not adding tabViewModel here as opening up a tab down there does that.
		//FIXME: clean up that tech debt
		ContentFrameController(viewState: contentFrameState, groupName: groupName)
	}

    frameController.loadView()
	
	if(contentFrameState == .minimised){
		return frameController
	}
	
	openCFTabs(for: frameController, with: tabViewModels)
	
	if(1 == tabViewModels.count && tabViewModels[0].type == .img){
		frameController.myView.fixedFrameRatio = true
	}
	
    return frameController
}

func openCFTabs(for controller: ContentFrameController, with tabViewModels: [TabViewModel]){
	if(controller.viewState == .frameless){
		if(0 < tabViewModels.count){
			let tab = tabViewModels[0]
			if(tab.type == .note){
				controller.openNoteInNewTab(contentId: tab.contentId, tabTitle: tab.title, content: tab.content)
			}else if(tab.type == .img && tab.icon != nil){
				controller.openImgInNewTab(contentId: tab.contentId, tabTitle: tab.title, content: tab.icon!, source: tab.source)
			}
		}
		return
	}
	
	var activeTab: Int = -1
	//loading tabs
	//TODO: refactor,- set TabModel and let the content controllerreopen the tabs
	for (i, tab) in tabViewModels.enumerated(){
		if(tab.state == .empty && tab.type == .web){
			_ = controller.openEmptyWebTab(tab.contentId)
		}else if(tab.type == .web){
			_ = controller.openWebsiteInNewTab(urlStr: tab.content, contentId: tab.contentId, tabName: tab.title, webContentState: tab.state)
		}else{
			//Everything else is not supported
			preconditionFailure("type: \(tab.type) is not supported in a tabbed contentFrame.")
		}
		if(tab.isSelected){
			activeTab = i
		}
	}
	if(0 <= activeTab){
		controller.forceSelectTab(at: activeTab)
	}
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
		var tabView = getTabViewModel(for: tabModel.id, ofType: tabModel.contentType, positioned: tabModel.position)
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
		for (i, _) in tabViews.enumerated(){
			tabViews[i].position = i
		}
	}
	
	return tabViews
}

func getTabViewModel(for id: UUID, ofType type: TabContentType, positioned at: Int) -> TabViewModel{
	var tabView: TabViewModel
	if(type == .web){
		let record = CachedWebTable.fetchCachedWebsite(contentId: id)
		tabView = TabViewModel(
			contentId: id,
			type: type,
			title: record.title,
			content: record.url,
			state: .notLoaded,
			position: at
		)
	}else if(type == .note){
		let record = NoteTable.fetchNote(contentId: id)
		tabView = TabViewModel(
			contentId: id,
			type: type,
			title: record.title,
			content: record.rawText,
			position: at
		)
	}else if(type == .img){
		let (title, img, sourceUrl) = ImgDal.fetchImgWMetaData(id: id) ?? (nil, nil, nil)
		tabView = TabViewModel(
			contentId: id,
			type: type,
			title: title ?? "",
			source: sourceUrl,
			icon: img
		)
	}else{
		preconditionFailure("unsupported type")
	}

	return tabView
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
