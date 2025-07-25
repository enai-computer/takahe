//Created on 02.10.23

import Cocoa
import WebKit
import PDFKit

let maxWidthMargin: CGFloat = 30.0

/**
	do NOT use this if viewState is `.sectionTitle` - Do not use this for SectionTitleViewController!
 */
func openEmptyContentFrame(viewState: NiContentFrameState = .expanded, groupName: String? = nil, groupId: UUID?) -> ContentFrameController{
	let frameController = ContentFrameController(
		viewState: viewState,
		groupName: groupName,
		groupId: groupId,
		tabsModel: nil)
	frameController.loadView()
	return frameController
}

func reopenContentFrame(screenSize: CGSize, contentFrame: NiContentFrameModel, tabDataModel: [NiCFTabModel]) -> CFProtocol{
	
	//special case handling
	guard contentFrame.state != .sectionTitle else {
		let sectionController = CFSectionTitleViewController(
			sectionId: contentFrame.id ?? UUID(), sectionName: contentFrame.name
		)
		sectionController.view.frame = initPositionAndSize(
			for: sectionController.myView,
			maxWidth: (screenSize.width - maxWidthMargin),
			contentFrame: contentFrame
		)
		return sectionController
	}
	
	let tabViewModels = niCFTabModelToTabViewModel(tabs: tabDataModel)
	let controller = reopenContentFrameWithOutPositioning(
		screenWidth: screenSize.width,
		contentFrameState: contentFrame.state,
		prevState: contentFrame.previousDisplayState,
		tabViewModels: tabViewModels,
		groupName: contentFrame.name,
		groupId: contentFrame.id
	)
	//positioning
	if(controller.viewState == .fullscreen){
		controller.view.frame.size = screenSize
		controller.view.frame.origin.y = contentFrame.position.y.px
	}else{
		controller.view.frame = initPositionAndSize(
			for: controller.myView,
			maxWidth: (screenSize.width - maxWidthMargin),
			contentFrame: contentFrame
		)
	}
	
	if(controller.tabs.count != tabViewModels.count){
		print("Content missing: Expected number of content Elements: \(tabViewModels.count) actual number: \(controller.tabs.count).")
	}
	
	return controller
}

func reopenContentFrameWithOutPositioning(
	screenWidth: CGFloat,
	contentFrameState: NiContentFrameState,
	prevState: NiPreviousDisplayState?,
	tabViewModels: [TabViewModel],
	groupName: String?,
	groupId: UUID?
) -> CFProtocol {
    
	let frameController = if(contentFrameState.isMinimized()){
		ContentFrameController(viewState: contentFrameState,
							   groupName: groupName,
							   groupId: groupId,
							   tabsModel: tabViewModels,
							   previousDisplayState: prevState
		)
	}else{
		// we are not adding tabViewModel here as opening up a tab down there does that.
		//FIXME: clean up that tech debt
		ContentFrameController(
			viewState: contentFrameState,
			groupName: groupName,
			groupId: groupId,
			previousDisplayState: prevState
		)
	}

    frameController.loadView()
	
	if(contentFrameState.isMinimized()){
		return frameController
	}
	
	openCFTabs(for: frameController, with: tabViewModels)

    return frameController
}

func openCFTabs(for controller: ContentFrameController, with tabViewModels: [TabViewModel]){
	if(controller.viewState == .frameless || controller.viewState == .simpleFrame){
		if(0 < tabViewModels.count){
			let tab = tabViewModels[0]
			if(tab.type == .note){
				controller.openNoteInNewTab(contentId: tab.contentId, tabTitle: tab.title, content: tab.content)
			}else if(tab.type == .sticky){
				let color: StickyColor = (tab.data as? StickyColor) ?? .yellow
				controller.openStickyInNewTab(contentId: tab.contentId, tabTitle: tab.title, content: tab.content, color: color)
			}else if(tab.type == .img && tab.icon != nil){
				controller.openImgInNewTab(contentId: tab.contentId, tabTitle: tab.title, content: tab.icon!, source: tab.source)
			}else if(tab.type == .pdf && tab.data != nil){
				controller.openPdfInNewTab(contentId: tab.contentId, tabTitle: tab.title, content: (tab.data as! PDFDocument), source: tab.source, scrollTo: tab.scrollPosition)
			}else if(tab.type == .web){
				_ = controller.openWebsiteInNewTab(urlStr: tab.content, contentId: tab.contentId, tabName: tab.title, webContentState: tab.state)
			}else if(tab.type == .eveChat){
				_ = controller.openWebsiteInNewTab(
					urlStr: tab.content,
					contentId: tab.contentId,
					tabName: tab.title,
					webContentState: .loaded,
					as: .eveChat
				)
			}
		}
		return
	}
	
	var activeTab: Int = -1
	//loading tabs
	//TODO: refactor,- set TabModel and let the content controllerreopen the tabs
	for (i, tab) in tabViewModels.enumerated(){
		if(tab.state == .empty && tab.type == .web){
			//if we reload tabheads here, they will not be loaded after all tab head were added --> not all tab heads would be shown
			_ = controller.openEmptyWebTab(tab.contentId, reloadTabHeads: false)
		}else if(tab.type == .web){
			_ = controller.openWebsiteInNewTab(urlStr: tab.content, contentId: tab.contentId, tabName: tab.title, webContentState: .notLoaded, loadWebsite: tab.isSelected)
		}else if(tab.type == .eveChat){
			_ = controller.openWebsiteInNewTab(
				urlStr: tab.content,
				contentId: tab.contentId,
				tabName: tab.title,
				webContentState: .loaded,
				as: .eveChat
			)
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
func initPositionAndSize(for view: CFBaseView, maxWidth: CGFloat, contentFrame: NiContentFrameModel) -> NSRect {
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
		let maxX = maxWidth - view.minContentFrameExposure
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
		var tabView = getTabViewModel(
			for: tabModel.id,
			ofType: tabModel.contentType,
			positioned: tabModel.position,
		 	scrollPosition: tabModel.scrollPosition,
			state: tabModel.contentState
		)
		if(tabModel.position < 0 || tabs.count <= tabModel.position){
			tabPositionCorrectionNeeded = true
		}
		
		if(tabModel.active && !activeTabSet){
			tabView.isSelected = true
			activeTabSet = true
		}else{
			tabView.isSelected = false
		}
		tabViews.append(tabView)
	}
	
	if(tabPositionCorrectionNeeded){
		for (i, _) in tabViews.enumerated(){
			tabViews[i].position = i
		}
	}
	
	return tabViews
}

func getTabViewModel(for id: UUID, ofType type: TabContentType, positioned at: Int, scrollPosition: Int?, state: String?) -> TabViewModel{
	var tabView: TabViewModel
	if(type == .web){
		let record = CachedWebTable.fetchCachedWebsite(contentId: id)
		tabView = TabViewModel(
			contentId: id,
			type: type,
			title: record?.title ?? "Blank Page",
			content: record?.url ?? "https://enai.io",
			state: .notLoaded,
			position: at
		)
	}else if(type == .eveChat){
		let record = ContentTable.fetchURLTitleSource(for: id)
		tabView = TabViewModel(
			contentId: id,
			type: .eveChat,
			title: record?.1 ?? "Blank Page",
			content: getEmtpyWebViewURL().absoluteString,
			state: TabViewModelState(rawValue: state ?? "notLoaded") ?? .notLoaded,
			position: at
		)
	}else if(type == .note){
		let record = NoteTable.fetchNote(contentId: id)
		tabView = TabViewModel(
			contentId: id,
			type: type,
			title: record?.title ?? "",
			content: record?.rawText ?? "",
			position: at
		)
	}else if(type == .sticky){
		let record = NoteTable.fetchNote(contentId: id)
		tabView = TabViewModel(
			contentId: id,
			type: type,
			title: record?.title ?? "",
			content: record?.rawText ?? "",
			data: StickyColor(rawValue: state ?? "yellow"),
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
	} else if(type == .pdf){
		let (title, pdf, sourceUrl) = PdfDal.fetchPdfWMetaData(id: id) ?? (nil, nil, nil)
		tabView = TabViewModel(
			contentId: id,
			type: type,
			title: title ?? "",
			source: sourceUrl,
			data: pdf,
			scrollPosition: scrollPosition
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
