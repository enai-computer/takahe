//
//  EveChatView.swift
//  ni
//
//  Created by Patrick Lukas on 28/9/24.
//
import Cocoa
import NativeMarkKit


class EveChatView: NSView{
	
	@IBOutlet var questionLabel: NSTextField!	
	@IBOutlet var answerTextView: NSTextView!
	
	private var mdTextView: NativeMarkLabel?
	
	func style(){
		wantsLayer = true
		layer?.cornerRadius = 4.0
		layer?.cornerCurve = .continuous
		
		layer?.backgroundColor = NSColor.sand2.cgColor
		answerTextView.backgroundColor = NSColor.sand2
	}
	
	func setText(markdown:String){
		mdTextView = NativeMarkLabel(nativeMark: markdown, styleSheet: getStylesheet())
		mdTextView?.frame = answerTextView.frame
		mdTextView?.wantsLayer = true
		mdTextView?.layer?.borderColor = NSColor.sand2.cgColor

		answerTextView.removeFromSuperview()
		addSubview(mdTextView!)
	}
	
	private func getStylesheet() -> StyleSheet{
		
		let myFont = FontName.custom("Sohne-Buch")
		let myTintColor = NSColor.birkin
		return StyleSheet.default.mutate(
		  block: [
			  .document: [
				.textStyle(.custom(name: myFont, size: FontSize.scaled(to: .body))),
				.backgroundColor(NSColor.sand2)
			  ],
			  .heading(level: 1): [
				.textStyle(.custom(name: myFont, size: FontSize.scaled(to: .largeTitle))),
				.backgroundColor(NSColor.sand2)
			  ],
			  .heading(level: 2): [
				.textStyle(.custom(name: myFont, size: FontSize.scaled(to: .title1))),
				.backgroundColor(NSColor.sand2)
			  ],
			  .heading(level: 3): [
				.textStyle(.custom(name: myFont, size: FontSize.scaled(to: .title2))),
				.backgroundColor(NSColor.sand2)
			  ],
			  .heading(level: 4): [
				.textStyle(.custom(name: myFont, size: FontSize.scaled(to: .title3))),
				.backgroundColor(NSColor.sand2)
			  ]
	  ],
	  inline: [
		  .link: [
			  .textColor(myTintColor)
		  ]
	  ]
  )
	}
}
