//
//  NiSearchResultViewItemRightIcon.swift
//  ni
//
//  Created by Patrick Lukas on 12/6/24.
//

import Cocoa

class ReturnIconView: NSImageView{
	static let instance = ReturnIconView()
	
	private init(){
		super.init(frame: NSRect(origin: CGPoint(x: 12.0, y: 0.5), size: NSImage.returnIcon.size))
		image = NSImage.returnIcon
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		ReturnIconView.instance.contentTintColor = NSColor.sand9
	}
}

class NiSearchResultViewItemRightIcon: NSView {
	
	private var shortcut: NSTextField? = nil
	private var keySelectedIcon: NSImageView? = nil
	private var position: Int?
	
	func configureElement(_ position: Int){
		//needed as parent ViewItem gets recylced
		shortcut?.removeFromSuperview()
		keySelectedIcon?.removeFromSuperview()
		
		self.position = position
		displayShortcut()
	}
	
	override func prepareForReuse(){
		//we cannot just call shortcut.removeFromSuperview().
		//As we may loose the refernce, but it still will be shown in the UI
		for v in subviews{
			v.removeFromSuperview()
		}
	}
	
	func displayShortcut(){
		if(0 < position! && position! < 6){
			shortcut = NSTextField(labelWithString: getText(position!))
			shortcut?.frame.size = self.frame.size
			shortcut?.textColor = NSColor.sand9
			shortcut?.font = NSFont(name: "Sohne-Buch", size: 16.0)
			self.addSubview(shortcut!)
		}
	}
	
	func select(){
		shortcut?.removeFromSuperview()
		ReturnIconView.instance.prepareForReuse()
		keySelectedIcon = ReturnIconView.instance
		//Needs to be async as otherwise deselect may be called on the imageview before select
		DispatchQueue.main.async {
			self.addSubview(self.keySelectedIcon!)
		}
	}
	
	func deselect(){
		keySelectedIcon?.removeFromSuperview()
		displayShortcut()
	}
	
	func preActionStyle(){
		keySelectedIcon?.contentTintColor = NSColor.sand1
		shortcut?.textColor = NSColor.sand1
	}
	
	private func getText(_ position: Int) -> String{
		return "⌘ \(position)"
	}
}
