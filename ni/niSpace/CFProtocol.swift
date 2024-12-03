//
//  CFProtocol.swift
//  Enai
//
//  Created by Patrick Lukas on 3/12/24.
//

import Cocoa

class CFProtocol: NSViewController{
	
	var viewState: NiContentFrameState = .expanded
	var myView: CFBaseView? {return view as? CFBaseView}
	var tabs: [TabViewModel] = []
	
	func toNiContentFrameModel() -> (model: NiDocumentObjectModel?, nrOfTabs: Int, state: NiContentFrameState?){
		fatalError("function not implemented")
	}
	
	func persistContent(spaceId: UUID){
		assertionFailure("function not implemented")
	}
	
	func purgePersistetContent(){
		assertionFailure("function not implemented")
	}
	
	/** Call this function ONLY from `setTopNiFrame` in `NiSpaceDocumentView`. Otherwise you will screw up the hierarchy on the canvas!
	 */
	func toggleActive(){
		myView.toggleActive()
	}
}
