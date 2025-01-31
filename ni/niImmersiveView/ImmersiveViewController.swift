//
//  ImmersiveViewController.swift
//  ni
//
//  Created by Patrick Lukas on 5/9/24.
//

//currently dead code. Needed for: https://linear.app/n-i/issue/NI-215/full-screen-mode-for-apps
import Cocoa
import WebKit

class ImmersiveViewController: NSViewController, WKNavigationDelegate, WKUIDelegate{
	
	private let viewFrame: NSRect
	private let urlReq: URLRequest
	
	init(frame: NSRect, urlReq: URLRequest) {
		self.viewFrame = frame
		self.urlReq = urlReq
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = getNewWebView(owner: self, urlReq: self.urlReq, frame: viewFrame)
	}
}
