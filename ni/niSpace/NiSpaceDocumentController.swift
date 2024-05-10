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
	
	private let emptySpaceID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
	
	private let niSpaceName: String
	private let niSpaceID: UUID
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
		self.niSpaceID = emptySpaceID
		self.niSpaceName = ""
		self.initHeight = nil
		self.spaceOpenedAt = Date()
		super.init(coder: coder)
	}
	
	override func loadView() {
		self.view = NiSpaceDocumentView(height: initHeight)
	}
	
	/**
	 Do not use before view is loaded, as CF View size gets calculated by the visibleRect
	*/
	func openEmptyCF(){
		let controller = openEmptyContentFrame()
		let newCFView = controller.myView
		newCFView.frame.origin = calculateOrigin(for: controller.view.frame)
		newCFView.setFrameOwner(myView)
		
		myView.addNiFrame(controller)
		
		_ = controller.openEmptyTab()
	}
	
	func closeTabOfTopCF(){
		myView.topNiFrame?.closeSelectedTab()
	}
	
	private func calculateOrigin(for frame: NSRect) -> CGPoint{
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
		
		return CGPoint(x: (x_center-x_dist_to_center), y: (y_center - y_dist_to_center))
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
	}
	
	func storeSpace(scrollPosition: CGFloat){
		
		if(self.niSpaceID == emptySpaceID){
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
			
			children.append(modelData.model)
			nrOfTabsInSpace += modelData.nrOfTabs
			if(modelData.state == .minimised){
				analyticsMinimized += 1
			}else{
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
