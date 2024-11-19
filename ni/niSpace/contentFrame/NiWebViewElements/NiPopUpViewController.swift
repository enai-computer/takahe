//
//  NiPopUpViewController.swift
//  Enai
//
//  Created by Patrick Lukas on 19/11/24.
//

import Cocoa
import WebKit

class NiPopUpViewController: NSViewController, WKUIDelegate, CFHeadActionImageDelegate{

	@IBOutlet var contentView: NSView!
	var niWebView: NiWebPopUp?
	weak var parentWV: NiWebView?
	@IBOutlet var handlebar: NSView!
	
	private let desiredConfig: WKWebViewConfiguration
	
	init(with wkConfig: WKWebViewConfiguration, for parentWV: NiWebView){
		desiredConfig = wkConfig
		self.parentWV = parentWV
		super.init(nibName: NSNib.Name("NiPopUpView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
		niWebView = NiWebPopUp(frame: contentView.bounds, configuration: desiredConfig)
		if let niWebView = niWebView {
			niWebView.translatesAutoresizingMaskIntoConstraints = false
			contentView.addSubview(niWebView)
			
			// Add constraints to bind niWebView to contentView
			NSLayoutConstraint.activate([
				niWebView.topAnchor.constraint(equalTo: contentView.topAnchor),
				niWebView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
				niWebView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
				niWebView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
			])
		}
		niWebView?.uiDelegate = self
		handlebar.removeFromSuperview()
		contentView.addSubview(handlebar)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		styleHandlebar()
		stlyeWebview()
		setDropShadow()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		updateShadowPaths()
	}
	
	private func styleHandlebar(){
		handlebar.wantsLayer = true
		handlebar.layer?.backgroundColor = NSColor.sand5.cgColor
		handlebar.layer?.cornerRadius = 10.0
		handlebar.layer?.cornerCurve = .continuous
		handlebar.layer?.maskedCorners = .layerMinXMinYCorner
		handlebar.layer?.zPosition = 1
	}
	
	private func stlyeWebview(){
		niWebView?.wantsLayer = true
		niWebView?.layer?.cornerCurve = .continuous
		niWebView?.layer?.cornerRadius = 10.0
		
	}
	
	private func setDropShadow(){
		view.clipsToBounds = false
		view.wantsLayer = true
		
		view.layer?.shadowColor = NSColor.sand115.cgColor
		view.layer?.shadowOffset = CGSize(width: 0.0, height: -1.0)
		view.layer?.shadowOpacity = 0.33
		view.layer?.shadowRadius = 3.0
		view.layer?.masksToBounds = false
		
		let dropShadow2 = CALayer(layer: view.layer!)
		dropShadow2.shadowPath = NSBezierPath(rect: view.bounds).cgPath
		dropShadow2.shadowColor = NSColor.sand115.cgColor
		dropShadow2.shadowOffset = CGSize(width: 2.0, height: -4.0)
		dropShadow2.shadowOpacity = 0.2
		dropShadow2.shadowRadius = 6.0
		dropShadow2.masksToBounds = false

		view.layer?.insertSublayer(dropShadow2, at: 0)
		
		let dropShadow3 = CALayer(layer: view.layer!)
		dropShadow3.shadowPath = NSBezierPath(rect: view.bounds).cgPath
		dropShadow3.shadowColor = NSColor.sand115.cgColor
		dropShadow3.shadowOffset = CGSize(width: 4.0, height: -8.0)
		dropShadow3.shadowOpacity = 0.2
		dropShadow3.shadowRadius = 20.0
		dropShadow3.masksToBounds = false

		dropShadow2.insertSublayer(dropShadow3, at: 0)
	}
	
	private func updateShadowPaths() {
		let path = NSBezierPath(rect: view.bounds).cgPath
		view.layer?.shadowPath = path
		if let dropShadow2 = view.layer?.sublayers?.first as? CALayer {
			dropShadow2.shadowPath = path
			if let dropShadow3 = dropShadow2.sublayers?.first as? CALayer {
				dropShadow3.shadowPath = path
			}
		}
	}
	
	func isButtonActive(_ type: CFHeadButtonType) -> Bool {
		return true
	}
	
	func mouseUp(with event: NSEvent, for type: CFHeadButtonType) {
		if(type == .close){
			removeFromParent()
		}
	}

	override func removeFromParent() {
		parentWV?.popUpClosed()
		view.removeFromSuperview()
		super.removeFromParent()
	}
	
	//MARK: WKUIDelegate functions
	func webViewDidClose(_ webView: WKWebView) {
		removeFromParent()
	}
	
	func webView(_ webView: WKWebView, didFinish: WKNavigation!){
		print("called didFinish")
	}
	
	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView)
	}
	
	func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error){
		handleFailedLoad(webView)
	}
	
	private func handleFailedLoad(_ webView: WKWebView){
		let errorURL = getCouldNotLoadWebViewURL()
		webView.loadFileURL(errorURL, allowingReadAccessTo: errorURL.deletingLastPathComponent())
	}
}
