//
//  CFSectionTitleViewController.swift
//  Enai
//
//  Created by Patrick Lukas on 3/12/24.
//

import Cocoa

class CFSectionTitleViewController: NSViewController, CFProtocol{

	private var sectionName: String? = nil
	private var sectionId: UUID
	
	//view state
	private var myView: CFSectionTitleView? {return view as? CFSectionTitleView}
	private var closeTriggered: Bool = false
	var viewState: NiContentFrameState = .sectionTitle
	var tabs: [TabViewModel] = []
	
	
	init(sectionId: UUID = UUID(), sectionName: String?){
		self.sectionId = sectionId
		self.sectionName = sectionName
		super.init(nibName: "CFSectionTitleView", bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		myView?.initAfterViewLoad(sectionName: sectionName)
	}
	
	/*
	 * MARK: - store and load here
	 */
	func persistContent(spaceId: UUID){
		if(closeTriggered){
			return
		}
		//TODO: double check how we want to store section titles
		//DocumentDal.persistGroup(id: groupId, name: groupName, spaceId: spaceId)
	}
	
	func purgePersistetContent(){}
	
	func toNiContentFrameModel() -> (model: NiDocumentObjectModel?, nrOfTabs: Int, state: NiContentFrameState?){
		
		let posInStack = Int(view.layer!.zPosition)
		let model = NiDocumentObjectModel(
			type: NiDocumentObjectTypes.contentFrame,
			data: NiContentFrameModel(
				state: .sectionTitle,
				previousDisplayState: nil,
				height: NiCoordinate(px: view.frame.height),
				width: NiCoordinate(px: view.frame.width),
				position: NiViewPosition(
					posInViewStack: posInStack,
					x: NiCoordinate(px: view.frame.origin.x),
					y: NiCoordinate(px: view.frame.origin.y)
				),
				children: [],
				name: self.sectionName,
				id: self.sectionId
			)
		)

		return (model: model, nrOfTabs: 0, state: NiContentFrameState.sectionTitle)
	}
}
