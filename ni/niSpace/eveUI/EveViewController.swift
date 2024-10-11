//
//  EveViewController.swift
//  ni
//
//  Created by Patrick Lukas on 9/10/24.
//
import Cocoa

class EveViewController: NSViewController, NSTextFieldDelegate{
	
	@IBOutlet var searchFieldBox: NSView!
	@IBOutlet var searchField: SearchViewTextField!
	@IBOutlet var placeholderView: NSView!
	
	private var contextUrls: [String] = []
	private var eveChatResultView: EveChatView?
	private var chatResultsShown: Bool = false
	
	init(){
		super.init(nibName: NSNib.Name("EveView"), bundle: Bundle.main)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func loadView() {
		super.loadView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillLayout() {
		view.wantsLayer = true
		stlyeSearchField()
		stlyeSearchFieldBox()
		super.viewWillLayout()
	}
	
	func addContextUrl(url: String){
		guard !url.isEmpty else {return}
		contextUrls.append(url)
	}
	
	private func stlyeSearchField(){
		let attrs = [NSAttributedString.Key.foregroundColor: NSColor.sand11,
					 NSAttributedString.Key.font: NSFont(name: "Sohne-Buch", size: 21.0)]
		
		searchField.placeholderAttributedString = NSAttributedString(string: "What's next?", attributes: attrs as [NSAttributedString.Key : Any])
		
		searchField.focusRingType = .none
	}
	
	private func stlyeSearchFieldBox(){
		searchFieldBox.wantsLayer = true
		searchFieldBox.layer?.backgroundColor = NSColor.sand1.cgColor
		searchFieldBox.layer?.cornerRadius = 8.0
		searchFieldBox.layer?.cornerCurve = .continuous
	}
	
	func getAnswerFromEve(){
		let question = searchField.stringValue
		searchField.stringValue = "Thinking ..."
		searchField.isEditable = false
		
		eveChatResultView = (NSView.loadFromNib(nibName: "EveChatView", owner: self) as! EveChatView)
		eveChatResultView?.questionLabel.stringValue = question
		
		eveChatResultView?.frame = placeholderView.frame
		eveChatResultView?.style()
		
		placeholderView.removeFromSuperview()
		view.addSubview(eveChatResultView!)
		chatResultsShown = true
		
		Task{
			let mdResult = await Eve.instance.askWContext(question: question,
														  context: contextUrls)
			eveChatResultView?.setText(markdown: mdResult)
			searchField.isEditable = true
			searchField.stringValue = ""
		}
	}
}
