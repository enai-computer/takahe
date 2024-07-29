//
//  NiLibraryViewController.swift
//  ni
//
//  Created by Patrick Lukas on 27/7/24.
//

import Cocoa

class NiLibraryViewController: NSViewController{
	
	@IBOutlet var classMoviesConnection: NiLibraryConnectionViewElement!
	@IBOutlet var functionalConnection: NiLibraryConnectionViewElement!
	
	init(){
		super.init(nibName: NSNib.Name("NiLibraryView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		view.layer?.cornerRadius = 20.0
		view.layer?.cornerCurve = .continuous
		view.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		
		if let myView = view as? NiLibraryView{
			myView.setHoverStateImgs()
		}
		
//		functionalConnection.mouseDownFunction = showConnectionDetails
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
	}
	
	func showConnectionDetails(with event: NSEvent){
		let imgSize = CGSize(width: 523.0, height: 85.0)
		let imgOrigin = CGPoint(
			x: functionalConnection.frame.midX - 16.0,
			y: functionalConnection.frame.midY + 16.0 - imgSize.height)
		let img = fetchImgFromMainBundle(id: UUID(uuidString: "1DA3C6AF-A701-418E-AB8C-B73285A3ECAB")!, type: ".png")!
		img.size = imgSize
		let imgView = NSImageView(frame: NSRect(origin: imgOrigin, size: imgSize))
		imgView.image = img
		view.addSubview(imgView)
	}
	
	func showConnections(with event: NSEvent){
		if let myView = self.view as? NiLibraryView{
			myView.hideSpaces()
		}
		classMoviesConnection.isHidden = false
		functionalConnection.isHidden = false
		
	}
}


