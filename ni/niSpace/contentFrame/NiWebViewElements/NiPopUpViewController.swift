//
//  NiPopUpViewController.swift
//  Enai
//
//  Created by Patrick Lukas on 19/11/24.
//

import Cocoa
import WebKit

class NiPopUpViewController: NSViewController, WKUIDelegate{

	@IBOutlet var contentView: NSView!
	var niWebView: NiWebPopUp?
	@IBOutlet var handlebar: NSView!
	
	private let desiredConfig: WKWebViewConfiguration
	
	init(with wkConfig: WKWebViewConfiguration){
		desiredConfig = wkConfig
		super.init(nibName: NSNib.Name("NiPopUpView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		niWebView = NiWebPopUp(frame: contentView.bounds, configuration: desiredConfig)
		contentView.addSubview(niWebView!)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		styleHandlebar()
	}
	
	private func styleHandlebar(){
		handlebar.wantsLayer = true
		handlebar.layer?.backgroundColor = NSColor.sand5.cgColor
		handlebar.layer?.cornerRadius = 10.0
		handlebar.layer?.cornerCurve = .continuous
		handlebar.layer?.maskedCorners = .layerMinXMinYCorner
		handlebar.layer?.zPosition = 1
	}
	
	func webViewDidClose(_ webView: WKWebView) {
		view.removeFromSuperview()
		removeFromParent()
	}
}
