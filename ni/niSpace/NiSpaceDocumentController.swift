//
//  NiSpaceDocumentController.swift
//  ni
//
//  Created by Patrick Lukas on 23/4/24.
//

import Cocoa
import PostHog

class NiSpaceDocumentController: NSViewController{
	
	var myView: NiSpaceDocumentView {return self.view as! NiSpaceDocumentView}
	
	private let defaultCFSize: CGSize = CGSize(width: 1400, height: 880)
	private let defaultNoteSize: CGSize = CGSize(width: 300, height: 200)
	private let bufferToTop: CGFloat = 45.0
	private let bufferToSides: CGFloat = 40.0
	
	static let EMPTY_SPACE_ID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
	static let DEMO_GEN_SPACE_ID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
	
	var niSpaceName: String
	let niSpaceID: UUID
	private let initHeight: CGFloat?
	private let spaceOpenedAt: Date
	
	private var leastRecentlyUsedOrigin: CGPoint? = nil
	private var leastRecentlyUsedOriginFactor: CGFloat = 1
	
	init(id: UUID, name: String, height: CGFloat? = nil) {
		self.niSpaceID = id
		self.niSpaceName = name
		self.initHeight = height
		self.spaceOpenedAt = Date()
		super.init(nibName: nil, bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		self.niSpaceID = NiSpaceDocumentController.EMPTY_SPACE_ID
		self.niSpaceName = ""
		self.initHeight = nil
		self.spaceOpenedAt = Date()
		super.init(coder: coder)
	}
	
	override func loadView() {
		var windowSize: CGSize? = AppDelegate.defaultWindowSize
		if(windowSize == nil){
			windowSize = NSApplication.shared.mainWindow?.frame.size ?? CGSize(width: 1600.0, height: 1000.0)
		}
		self.view = NiSpaceDocumentView(windowSize: windowSize!)
	}
	
	/**
	 Do not use before view is loaded, as CF View size gets calculated by the visibleRect
	*/
	@discardableResult
	func openEmptyCF(viewState: NiConentFrameState = .expanded,
					 initialTabType: TabContentType = .web,
					 openInitalTab: Bool = true,
					 positioned relavtiveTo: CGPoint? = nil,
					 size: CGSize? = nil,
					 content: String? = nil,
					 groupName: String? = nil
	) -> ContentFrameController {
		let controller = openEmptyContentFrame(viewState: viewState, groupName: groupName)
		let newCFView = controller.myView
		
		//TODO: set location & size dependent on viewState
		if(initialTabType == .note && size == nil){
			newCFView.frame.size = defaultNoteSize
		}else if(size != nil){
			newCFView.frame.size = size!
		}else{
			newCFView.frame.size = defaultCFSize
			if(view.frame.width < newCFView.frame.width){
				newCFView.frame.size.width = view.frame.width - (bufferToSides * 2.0)
			}
		}
		
		if(relavtiveTo == nil){
			newCFView.frame.origin = calculateContentFrameOrigin(for: controller.view.frame)
		}else{
			newCFView.frame.origin = calculateOrigin(for: controller.view.frame, relativeTo: relavtiveTo!)
		}
		
		newCFView.setFrameOwner(myView)
		myView.addNiFrame(controller)
		
		//TODO: set inital tab type bassed on passed parameter
		if(initialTabType == .web && openInitalTab){
			controller.openAndEditEmptyWebTab()
		}else if(initialTabType == .note){
			controller.openNoteInNewTab(content: content)
		}
		
		return controller
	}
	
	func closeTabOfTopCF(){
		myView.topNiFrame?.closeSelectedTab()
	}
	
	func reloadTabOfTopCF(){
		myView.topNiFrame?.reloadSelectedTab()
	}
	
	private func calculateOrigin(for frame: NSRect, relativeTo: CGPoint) -> CGPoint{
		//TODO: calc out of bounds etc
		return CGPoint(x: relativeTo.x, y: relativeTo.y)
	}
	
	func calculateContentFrameOrigin(for frame: NSRect) -> CGPoint{
		let viewSize = view.visibleRect.size
		
		let x_center: Double
		let y_center: Double
		
		if(leastRecentlyUsedOrigin == nil || leastRecentlyUsedOrigin != view.visibleRect.origin){
			x_center = viewSize.width / 2
			y_center = view.visibleRect.origin.y + viewSize.height / 2
			leastRecentlyUsedOriginFactor = 1
		}else{
			x_center = leastRecentlyUsedOrigin!.x + viewSize.width / 2 + leastRecentlyUsedOriginFactor * 30
			y_center = leastRecentlyUsedOrigin!.y + viewSize.height / 2 + leastRecentlyUsedOriginFactor * 30
			leastRecentlyUsedOriginFactor += 1
		}
		leastRecentlyUsedOrigin = CGPoint(x: view.visibleRect.origin.x, y: view.visibleRect.origin.y)
		
		let x_dist_to_center = frame.width / 2
		let y_dist_to_center = frame.height / 2
		
		var yOrigin = (y_center - y_dist_to_center)
		if(yOrigin < bufferToTop){
			yOrigin = bufferToTop
		}
		var xOrigin = (x_center-x_dist_to_center)
		if(xOrigin < bufferToSides){
			xOrigin = bufferToSides
		}
		return CGPoint(x: xOrigin, y: yOrigin)
	}
	
	/*
	 * MARK: - load and store space document here
	 */
	
	func recreateSpace(docModel: NiDocumentObjectModel) -> NSPoint?{
		if (docModel.type == NiDocumentObjectTypes.document){
			let data = docModel.data as! NiDocumentModel
			let docModelChildren = data.children
			var contentFramesToRecreate: [NiContentFrameModel] = []
			
			//Ordering the CFs so they will appear in the same order again
			//we'll need to add the one at the bottom first
			//posInViewStack is the Z-Position of the CF smallest first and then upwards
			// the setTopNiFrame function will be called and automatically renumber the Cframes
			for child in docModelChildren{
				let childData = child.data as! NiContentFrameModel
				contentFramesToRecreate.append(childData)
			}
			let orderedCFsToRecreate = contentFramesToRecreate.sorted{
				$0.position.posInViewStack < $1.position.posInViewStack
			}
			
			for cfData in orderedCFsToRecreate{
				recreateContentFrame(data: cfData)
			}
			
			if (data.viewPosition != nil && 10.0 < data.viewPosition!.px){
				return NSPoint(x: 0.0, y: data.viewPosition!.px)
			}
		}
		return nil
	}
	
	private func recreateContentFrame(data: NiContentFrameModel){
		let storedWebsiteCFController = reopenContentFrame(screenWidth: self.view.frame.width, contentFrame: data, tabDataModel: data.children)
		myView.addNiFrame(storedWebsiteCFController)
		storedWebsiteCFController.myView.setFrameOwner(myView)
		
		if(storedWebsiteCFController.viewState == .fullscreen){
			(NSApplication.shared.delegate as? AppDelegate)?.getNiSpaceViewController()?.hideHeader()
		}
	}
	
	func storeSpace(scrollPosition: CGFloat){
		
		if(self.niSpaceID == NiSpaceDocumentController.EMPTY_SPACE_ID){
			return
		}
		
		if( !(NSApplication.shared.delegate as! AppDelegate).allowedToSaveSpace(self.niSpaceID)){
			print("not allowed to store page. Most likely due to loading issues.")
			return
		}
		
		let documentJson = genJson(scrollPosition: scrollPosition)
		//View json stored here
		DocumentTable.upsertDoc(id: niSpaceID, name: niSpaceName, document: documentJson)
		//Content of the CFs stored here
		myView.persistContent(documentId: niSpaceID)
	}
	
	private func genJson(scrollPosition: CGFloat) -> String{
		
		var children: [NiDocumentObjectModel] = []
		var analyticsMinimized: Int = 0
		var analyticsExpanded: Int = 0
		var nrOfTabsInSpace = 0
		
		for cfController in myView.contentFrameControllers {
			let modelData = cfController.toNiContentFrameModel()
			
			if (modelData.model != nil){
				children.append(modelData.model!)
			}
			nrOfTabsInSpace += modelData.nrOfTabs
			if(modelData.state == .minimised){
				analyticsMinimized += 1
			}else if(modelData.state == .expanded){
				analyticsExpanded += 1
			}
		}
			
		let toEncode = NiDocumentObjectModel(
			type: NiDocumentObjectTypes.document,
			data: NiDocumentModel(
				id: niSpaceID,
				height: myView.frame.height,
				width: myView.frame.width,
				children: children,
				viewPosition: scrollPosition
			)
		)
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		
		let minInSpace = (Date().timeIntervalSinceReferenceDate - spaceOpenedAt.timeIntervalSinceReferenceDate) / 60
		PostHogSDK.shared.capture("Space_saved",
								  properties: [
									"number_of_windows": children.count,
									"windows_expanded": analyticsExpanded,
									"windows_minimized": analyticsMinimized,
									"number_of_tabs": nrOfTabsInSpace,
									"length": myView.frame.height,
									"time_in_space_min": minInSpace
								  ]
		)
		
		do{
			let jsonData = try jsonEncoder.encode(toEncode)
			return String(data: jsonData, encoding: .utf8) ?? "FAILED GENERATING JSON"
		}catch{
			print(error)
		}
		return "FAILED GENERATING JSON"
	}
}
