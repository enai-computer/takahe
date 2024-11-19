//
//  NiWebPopUp.swift
//  Enai
//
//  Created by Patrick Lukas on 19/11/24.
//

import Cocoa
import WebKit


class NiWebPopUp: WKWebView{
	
	override init(frame: NSRect, configuration: WKWebViewConfiguration){
		super.init(frame: frame, configuration: configuration)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
