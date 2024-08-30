//
//  WeatherWidgetNSView.swift
//  ni
//
//  Created by Patrick Lukas on 29/8/24.
//

import Cocoa
import SwiftUI

class WeatherNSView: NSView {
	private var hostingView: NSHostingView<WeatherView>?
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		setupSwiftUIView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setupSwiftUIView()
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
}
