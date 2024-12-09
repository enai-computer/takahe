//
//  CFSectionTitleViewController.swift
//  Enai
//
//  Created by Patrick Lukas on 3/12/24.
//

import Cocoa
import Carbon.HIToolbox

class CFSectionTitleViewController: CFProtocol, NSTextFieldDelegate{

	private var sectionName: String? = nil
	private var sectionId: UUID
	
	//view state
	private var sectionView: CFSectionTitleView? {return view as? CFSectionTitleView}

	init(sectionId: UUID = UUID(), sectionName: String?){
		self.sectionId = sectionId
		self.sectionName = sectionName
		super.init(nibName: "CFSectionTitleView", bundle: Bundle.main)
		
		self.viewState = .sectionTitle
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		sectionView?.initAfterViewLoad(sectionName: sectionName, myController: self)
		sectionView?.sectionTitle.delegate = self
	}
	
	override func viewDidAppear() {
		sectionView?.setUnderline()
	}
	
	/*
	 * MARK: - Text Delegate functions
	 */
	func controlTextDidEndEditing(_ notification: Notification) {
		//needed as this is called on CollectionItem reload. idk why :O
		
		guard let textField = notification.object as? NiTextField else {
			sectionView?.niParentDoc?.unselectTopNiFrame()
			return
		}
		
		if(notification.userInfo?["NSTextMovement"] as? NSTextMovement == NSTextMovement.cancel){
			textField.stringValue = sectionName ?? "New section"
		}else{
			self.sectionName = textField.stringValue
		}
		
		sectionView?.niParentDoc?.unselectTopNiFrame()
	}
	
	/*
	 * MARK: key events here
	 */
	override func keyDown(with event: NSEvent) {
		if(event.keyCode == kVK_Delete || event.keyCode == kVK_ForwardDelete){
			if(sectionView?.frameIsActive == true){
				triggerCloseProcess(with: event)
				return
			}
		}
		super.keyDown(with: event)
	}
	
	/*
	 * MARK: - store and load here
	 */
	override func persistContent(spaceId: UUID){
		if(closeTriggered){
			return
		}
		//TODO: double check how we want to store section titles
		//DocumentDal.persistGroup(id: groupId, name: groupName, spaceId: spaceId)
	}
	
	override func purgePersistetContent(){}
	
	override func toNiContentFrameModel() -> (model: NiDocumentObjectModel?, nrOfTabs: Int, state: NiContentFrameState?){
		
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
