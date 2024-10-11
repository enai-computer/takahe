//
//  WeatherWidgetNSView.swift
//  ni
//
//  Created by Patrick Lukas on 29/8/24.
//

import Cocoa
import SwiftUI

class WeatherNSView: NSView {
	private(set) var hostingView: NSHostingView<WeatherView>?
	
	private var hoverEffect: NSTrackingArea?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setupSwiftUIView()
		setupTrackingArea()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupSwiftUIView()
		setupTrackingArea()
	}
	
	private func setupTrackingArea(){
//		hoverEffect = NSTrackingArea(rect: bounds,
//									 options: [.activeInKeyWindow, .mouseEnteredAndExited],
//									 owner: self,
//									 userInfo: nil)
//		addTrackingArea(hoverEffect!)
//		
//		wantsLayer = true
//		layer?.cornerRadius = 4.0
//		layer?.cornerCurve = .continuous
	}
	
	private func setupSwiftUIView() {
		let local = UserSettings.shared.homeViewWeatherLocation
		let swiftUIView = WeatherView(for: local)
		hostingView = NSHostingView(rootView: swiftUIView)
		
		if let hostingView = hostingView {
			hostingView.translatesAutoresizingMaskIntoConstraints = false
			addSubview(hostingView)
			
			NSLayoutConstraint.activate([
				hostingView.topAnchor.constraint(equalTo: topAnchor),
				hostingView.trailingAnchor.constraint(equalTo: trailingAnchor),
				hostingView.bottomAnchor.constraint(equalTo: bottomAnchor)
			])
		}
	}
	
//	override func mouseEntered(with event: NSEvent){
//		layer?.backgroundColor = NSColor.sand4.cgColor
//		NSCursor.pointingHand.push()
//	}
//	
//	override func mouseExited(with event: NSEvent){
//		layer?.backgroundColor = NSColor.clear.cgColor
//		NSCursor.pop()
//	}
}
