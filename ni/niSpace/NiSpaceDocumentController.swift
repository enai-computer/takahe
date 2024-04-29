//
//  NiSpaceDocumentController.swift
//  ni
//
//  Created by Patrick Lukas on 23/4/24.
//

import Cocoa

class NiSpaceDocumentController: NSViewController{
	
	var myView: NiSpaceDocumentView {return self.view as! NiSpaceDocumentView}
	
	private let emptySpaceID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
	
	private let niSpaceName: String
	private let niSpaceID: UUID
	private let initHeight: CGFloat?
	
	private var leastRecentlyUsedOrigin: CGPoint? = nil
	private var leastRecentlyUsedOriginFactor: CGFloat = 1
	
	init(id: UUID, name: String, height: CGFloat? = nil) {
		self.niSpaceID = id
		self.niSpaceName = name
		self.initHeight = height
		super.init(nibName: nil, bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		self.niSpaceID = emptySpaceID
		self.niSpaceName = ""
		self.initHeight = nil
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
		let newCFView = controller.niContentFrameView!
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
	
	func recreateSpace(docModel: NiDocumentObjectModel){
		if (docModel.type == NiDocumentObjectTypes.document){
			let data = docModel.data as! NiDocumentModel
			let children = data.children
			for child in children{
				let childData = child.data as! NiContentFrameModel
				recreateContentFrame(data: childData)
			}
		}
	}
	
	private func recreateContentFrame(data: NiContentFrameModel){
		let storedWebsiteCFController = reopenContentFrame(contentFrame: data, tabs: data.children)
		myView.addNiFrame(storedWebsiteCFController)
		storedWebsiteCFController.niContentFrameView!.setFrameOwner(myView)
	}
	
	func storeSpace(){
		
		if(self.niSpaceID == emptySpaceID){
			return
		}
		
		let documentJson = genJson()
		//View json stored here
		DocumentTable.upsertDoc(id: niSpaceID, name: niSpaceName, document: documentJson)
		//Content of the CFs stored here
		myView.persistContent(documentId: niSpaceID)
	}
	
	func genJson() -> String{
		
		var children: [NiDocumentObjectModel] = []
		for cfController in myView.contentFrameControllers {
			children.append(cfController.toNiContentFrameModel())
		}
			
		let toEncode = NiDocumentObjectModel(
			type: NiDocumentObjectTypes.document,
			data: NiDocumentModel(
				id: niSpaceID,
				height: myView.frame.height,
				width: myView.frame.width,
				children: children
			)
		)
		let jsonEncoder = JSONEncoder()
		jsonEncoder.outputFormatting = .prettyPrinted
		
		do{
			let jsonData = try jsonEncoder.encode(toEncode)
			return String(data: jsonData, encoding: .utf8) ?? "FAILED GENERATING JSON"
		}catch{
			print(error)
		}
		return "FAILED GENERATING JSON"
	}
}
