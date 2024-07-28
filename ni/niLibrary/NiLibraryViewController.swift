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
	@IBOutlet var spaceThubnail41: DemoLibraryImage!
	
	init(){
		super.init(nibName: NSNib.Name("NiLibraryView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func loadView() {
		super.loadView()
//		connector = (NSView.loadFromNib(nibName: "NiLibraryConnectionViewElement", owner: self) as! NiLibraryConnectionViewElement)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.wantsLayer = true
		view.layer?.cornerRadius = 20.0
		view.layer?.cornerCurve = .continuous
		view.layer?.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		
		functionalConnection.mouseDownFunction = showConnectionDetails
		spaceThubnail41.mouseDownFunction = showConnections
		setUp2ndImg()
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
	
	private func setUp2ndImg(){
		spaceThubnail41.setNonBlurredImg(id: UUID(uuidString: "694A8A7C-9A42-4C21-BF8D-58DFE577B291")!)
	}
}


