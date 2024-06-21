//
//  NiEmptyView.swift
//  ni
//
//  Created by Patrick Lukas on 17/6/24.
//

import Cocoa


class NiEmptyViewController: NSViewController{
	
	private var viewFrame: NSRect
	private var contentController: NSViewController
	
	init(viewFrame: NSRect, contentController: NSViewController) {
		self.viewFrame = viewFrame
		self.contentController = contentController
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		view = EmptyRectView(frame: viewFrame)
	}
	
	override func viewDidLoad() {
		view.addSubview(contentController.view)
	}
}
