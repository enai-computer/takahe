//
//  NiLibraryView.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryView: NSBox{
	
	@IBOutlet var contentBox: NSView!
	
	@IBOutlet var plants: DemoLibraryImage!
	@IBOutlet var mindfulness: DemoLibraryImage!
	@IBOutlet var art: DemoLibraryImage!
	@IBOutlet var groupProject: DemoLibraryImage!
	@IBOutlet var attention: DemoLibraryImage!
	@IBOutlet var berlin: DemoLibraryImage!
	@IBOutlet var mlSysDesign: DemoLibraryImage!
	@IBOutlet var books: DemoLibraryImage!
	@IBOutlet var cooking: DemoLibraryImage!
	@IBOutlet var jets: DemoLibraryImage!
	@IBOutlet var interface: DemoLibraryImage!
	@IBOutlet var wedding: DemoLibraryImage!
	@IBOutlet var hciFoundations: DemoLibraryImage!
	@IBOutlet var introOS: DemoLibraryImage!
	@IBOutlet var ski: DemoLibraryImage!
	
	@IBOutlet var groupConnector5: NiLibraryConnectionViewElement!
	@IBOutlet var groupConnector4: NiLibraryConnectionViewElement!
	@IBOutlet var groupConnector3: NiLibraryConnectionViewElement!
	@IBOutlet var groupConnector2: NiLibraryConnectionViewElement!
	@IBOutlet var groupConnector1: NiLibraryConnectionViewElement!
	@IBOutlet var fighterJetsConnector: NiLibraryConnectionViewElement!
	
	private var groupPojectActive: Bool = false
	private var jetSpaceActive: Bool = false
	private var connectorBoxesToHide: [NiLibraryInfoBox] = []
	
	func setHoverStateImgs(){
		attention.setHoverImg("payAttentionU")
		mlSysDesign.setHoverImg("MLsysDesignU")
		books.setHoverImg("booksU")
		cooking.setHoverImg("cookingU")
		jets.setHoverImg("jetsU")
		interface.setHoverImg("interfacesU")
		wedding.setHoverImg("weddingU")
		hciFoundations.setHoverImg("HCIU")
		introOS.setHoverImg("introOSU")
		berlin.setHoverImg("BerlinU")
		groupProject.setHoverImg("groupProU")
		art.setHoverImg("artU")
		mindfulness.setHoverImg("mindfulnessU")
		plants.setHoverImg("plantsU")
		ski.setHoverImg("skiU")
		
		groupProject.mouseDownFunction = self.showGroupConnections
		jets.mouseDownFunction = self.showJetConenctios
		
		fighterJetsConnector.mouseDownFunction = showJetConnectionDetails
		groupConnector1.mouseDownFunction = showInterfaceGroupDetails
		groupConnector2.mouseDownFunction = showCSGroupDetails
		groupConnector3.mouseDownFunction = showArtGroupDetails
		groupConnector4.mouseDownFunction = showHCIGroupDetails
		groupConnector5.mouseDownFunction = showAttentionGroupDetails
	}
	
	func showGroupConnections(with event: NSEvent){
		if(event.clickCount == 1){
			if(self.groupPojectActive){
				self.hideGroupProjConnections()
				self.groupPojectActive = false
			}else{
				self.showGroupProjConnections()
				self.groupPojectActive = true
			}
		}
	}
	
	func showJetConenctios(with event: NSEvent){
		if(event.clickCount == 1){
			if(self.jetSpaceActive){
				self.hideJetConnections()
				self.jetSpaceActive = false
			}else{
				self.showJetConnections()
				self.jetSpaceActive = true
			}
		}
		if(event.clickCount == 2){
			if let appDel = (NSApplication.shared.delegate as? AppDelegate){
				let spaceController = appDel.getNiSpaceViewController()
				spaceController?.loadSpace(spaceId: UUID(uuidString:"64DD09C6-D900-4C71-9127-7F5818E6AD11")!, name: "Fighter Jets")
				spaceController?.view.window?.makeKey()
			}
		}
	}
	
	func showGroupProjConnections(){
		toggleSpacesVisability()
		setVisability(false, for: [groupConnector1, groupConnector2, groupConnector3, groupConnector4, groupConnector5])
	}
	
	func toggleSpacesVisability(_ hide: Bool = true, forceHide: Bool = false){
		for v in contentBox.subviews{
			if let demoImage = v as? DemoLibraryImage{
				if(forceHide){
					demoImage.isHidden = hide
				}else if(hide){
					demoImage.tryHide()
				}else{
					demoImage.unhide()
				}
			}
		}
	}
	
	func hideGroupProjConnections(){
		for conBox in connectorBoxesToHide{
			conBox.removeFromSuperview()
		}
		connectorBoxesToHide = []
		toggleSpacesVisability(false)
		setVisability(for: [groupConnector1, groupConnector2, groupConnector3, groupConnector4, groupConnector5])
	}
	
	func showJetConnections(){
		toggleSpacesVisability(true, forceHide: true)
		setVisability(false, for: [jets, interface, fighterJetsConnector])
	}
	
	func hideJetConnections(){
		for conBox in connectorBoxesToHide{
			conBox.removeFromSuperview()
		}
		connectorBoxesToHide = []
		toggleSpacesVisability(false)
		setVisability(for: [fighterJetsConnector])
	}
	
	func setVisability(_ hide: Bool = true, for views: [NSView]){
		for v in views{
			v.isHidden = hide
		}
	}
	
	func showJetConnectionDetails(with event: NSEvent){
		showConnectionDetails(for: fighterJetsConnector, with: "jetsConnInfo", height: 149.0)
	}
	
	func showInterfaceGroupDetails(with event: NSEvent){
		showConnectionDetails(for: groupConnector1, with: "interfaceToGroup", height: 128.0)
	}
	
	func showCSGroupDetails(with event: NSEvent){
		showConnectionDetails(for: groupConnector2, with: "mlToGroup", height: 107.0)
	}
	
	func showArtGroupDetails(with event: NSEvent){
		showConnectionDetails(for: groupConnector3, with: "phenomenologyToGroup", height: 128.0)
	}
	
	func showHCIGroupDetails(with event: NSEvent){
		showConnectionDetails(for: groupConnector4, with: "hciToGroup", height: 128.0)
	}
	
	func showAttentionGroupDetails(with event: NSEvent){
		showConnectionDetails(for: groupConnector5, with: "anthToGroup", height: 128.0)
	}
	
	func showConnectionDetails(for connector: NiLibraryConnectionViewElement, with imageName: String, height: CGFloat){
		let imgSize = CGSize(width: 523.0, height: height)
		let imgOrigin = CGPoint(
			x: connector.frame.midX - 8.0,
			y: connector.frame.midY + 8.0 - imgSize.height
		)
		let img = NSImage(named: imageName)!
		img.size = imgSize
		let imgView = NiLibraryInfoBox(frame: NSRect(origin: imgOrigin, size: imgSize))
		imgView.image = img
		imgView.wantsLayer = true
		imgView.layer?.zPosition = 3
		addSubview(imgView)
		connectorBoxesToHide.append(imgView)
	}
}
