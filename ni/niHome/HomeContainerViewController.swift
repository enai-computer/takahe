//
//  HomeContainerController.swift
//  Enai
//
//  Created by Christian Tietze on 17.11.24.
//

import Cocoa

class HomeContainerViewController: NSViewController {
	typealias DismissHandler = (_ controller: HomeContainerViewController) -> Void

	let canBeDismissed: Bool
	lazy var homeController = NiHomeController()
	private let dismiss: DismissHandler

	required init(
		canBeDismissed: Bool,
		dismiss: @escaping DismissHandler
	) {
		self.canBeDismissed = canBeDismissed
		self.dismiss = dismiss
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

	override func loadView() {
		self.view = NSView()
		self.view.translatesAutoresizingMaskIntoConstraints = false

		self.addChild(homeController)
		self.view.addSubview(homeController.view)
		homeController.view.addConstraintsToFillSuperview()
	}

	override func cancelOperation(_ sender: Any?) {
		guard canBeDismissed else {
			NSSound.beep()
			return
		}
		dismiss(self)
	}
}
