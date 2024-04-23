//
//  NiSpaceDocumentController.swift
//  ni
//
//  Created by Patrick Lukas on 23/4/24.
//

import Cocoa

class NiSpaceDocumentController: NSViewController{
	
	private let emptySpaceID: UUID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
	
	private let niSpaceName: String
	private let niSpaceID: UUID
	
	private var leastRecentlyUsedOrigin: CGPoint? = nil
	
	init(id: UUID, name: String) {
		self.niSpaceID = id
		self.niSpaceName = name
		super.init(nibName: nil, bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		self.niSpaceID = emptySpaceID
		self.niSpaceName = ""
		super.init(coder: coder)
	}
	
	override func loadView() {
		self.view = NiSpaceDocumentView()
	}
	
	func openEmptyCF(){
		let controller = openEmptyContentFrame()
		let newCFView = controller.view as! ContentFrameView
		newCFView.frame.origin = calculateOrigin(for: controller.view.frame)
		
		myView.addNiFrame(controller)
		newCFView.setFrameOwner(myView)
	}
	
	func closeTabOfTopCF(){
		myView.topNiFrame?.removeSelectedTab()
	}
	
	private func calculateOrigin(for frame: NSRect) -> CGPoint{
		let windowSize = NSApplication.shared.keyWindow!.frame.size
		
		let x_center: Double
		let y_center: Double
		
		if(leastRecentlyUsedOrigin == nil){
			x_center = windowSize.width / 2
			y_center = windowSize.height / 2
		}else{
			x_center = leastRecentlyUsedOrigin!.x + 30
			y_center = leastRecentlyUsedOrigin!.y + 30
		}
		leastRecentlyUsedOrigin = CGPoint(x: x_center, y: y_center)
		
		let x_dist_to_center = frame.width / 2
		let y_dist_to_center = frame.height / 2
		
		return CGPoint(x: (x_center-x_dist_to_center), y: (y_center - y_dist_to_center))
	}
	/*
	 * MARK: - load and store space document here
	 */
	
	var myView: NiSpaceDocumentView {return self.view as! NiSpaceDocumentView}
	
	func loadStoredSpace(niSpaceID: UUID){
		do{
			let docJson = (DocumentTable.fetchDocumentModel(id: niSpaceID)?.data(using: .utf8))!
			let jsonDecoder = JSONDecoder()
			let docModel = try jsonDecoder.decode(NiDocumentObjectModel.self, from: docJson)
			if (docModel.type == NiDocumentObjectTypes.document){
				let data = docModel.data as! NiDocumentModel
				let children = data.children
				for child in children{
					let childData = child.data as! NiContentFrameModel
					recreateContentFrame(data: childData)
				}
			}
		}catch{
			print(error)
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
		DocumentTable.upsertDoc(id: niSpaceID, name: niSpaceName, document: documentJson)
		myView.persistContent(documentId: niSpaceID)
	}
	
	func genJson() -> String{
		
		var children: [NiDocumentObjectModel] = []
		for cfController in myView.drawnNiFrames {
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
