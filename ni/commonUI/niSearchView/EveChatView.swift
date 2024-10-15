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
	@IBOutlet var scrollView: NSScrollView!
	@IBOutlet var answerTextPlaceholder: NSView!
	private let padding_QLabel_Answer = 8.0
	private var mdTextView: NativeMarkLabel?
	
	func style(){
		wantsLayer = true
		layer?.cornerRadius = 4.0
		layer?.cornerCurve = .continuous
		layer?.backgroundColor = NSColor.sand2.cgColor
	}
	
	func setText(markdown:String){
		mdTextView = NativeMarkLabel(nativeMark: markdown, styleSheet: getStylesheet())
		mdTextView?.frame.origin = answerTextPlaceholder.frame.origin
		mdTextView?.frame.size.width = answerTextPlaceholder.frame.size.width
		
		mdTextView?.frame.size.height = mdTextView!.getIntrinsicContentSize(width: answerTextPlaceholder.frame.size.width).height
		
		mdTextView?.wantsLayer = true
		mdTextView?.layer?.borderColor = NSColor.sand2.cgColor
		
		let newFrameHeight = mdTextView!.frame.height + padding_QLabel_Answer + questionLabel.frame.height
		if(scrollView.documentView!.frame.size.height < newFrameHeight){
			scrollView.documentView?.frame.size.height = newFrameHeight
		}else{
			mdTextView?.frame.origin.y = answerTextPlaceholder.frame.origin.y + (answerTextPlaceholder.frame.height - mdTextView!.frame.height)
		}
		
		answerTextPlaceholder.removeFromSuperviewWithoutNeedingDisplay()
		scrollView.documentView?.addSubview(mdTextView!)
	}
	
	private func getStylesheet() -> StyleSheet{
		
		let myFont = FontName.custom("Sohne-Buch")
		let myTintColor = NSColor.birkin
		return StyleSheet.default.mutate(
		  block: [
			  .document: [
				.textStyle(.custom(name: myFont, size: FontSize.fixed(16.0))),
				.backgroundColor(NSColor.sand2),
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
