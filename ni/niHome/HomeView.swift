//
//  HomeView.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import SwiftUI
import Cocoa

let stdCorner = RectangleCornerRadii(
	topLeading: 5,
	bottomLeading: 5,
	bottomTrailing: 5,
	topTrailing: 5
)

let NewSpaceID = UUID(uuidString: "00000000-0000-0000-0000-000000000000")

class ControllerWrapper{
	weak var hostingController: HomeViewController?
}

struct HomeView: View {
	@Namespace var homeViewNameSpace
	
	var lstOfSpaces = DocumentTable.fetchListofDocs()
	let controllerWrapper: ControllerWrapper
	let width: CGFloat
	let height: CGFloat
	
	init(_ controllerWrapper: ControllerWrapper, width: CGFloat, height: CGFloat){
		self.controllerWrapper = controllerWrapper
		self.width = width
		self.height = height
	}
	
    var body: some View {
		VStack{
			HStack(alignment:.center, spacing: 0.0) {
				LeftSide()
					.frame(width: (self.width*(3/8)), height: self.height)
					.scaledToFit()
					.background(Color.leftSideBackground)
				RightSide(controllerWrapper, inNamespace: homeViewNameSpace, listOfSpaces: lstOfSpaces)
					.frame(width: (self.width*(5/8)), height: self.height)
					.scaledToFit()
					.background(Color.rightSideBackground)
					.prefersDefaultFocus(in: homeViewNameSpace)
			}
		}.frame(width: width, height: height)
	}
}

struct LeftSide: View {
	var body: some View {
		VStack{
			Spacer().frame(maxHeight: 150)
			Text("\(getWelcomeMessage()), \(NSUserName())")
				.font(Font.custom("soehne-buch", size: 24))
				.foregroundStyle(.sandLight11)
			Spacer()
		}
	}
}



/*
 * MARK: - right side
 */
struct RightSide: View {
	let homeViewNameSpace: Namespace.ID
	
	let controllerWrapper: ControllerWrapper
	
	@State var textFieldInput: String = ""
	@State var textFieldDisabled: Bool = false
	@State var predictableValues: Array<NiDocumentViewModel>
	@State var predictedValues: Array<NiDocumentViewModel> = []
	
	@State var selection: NiDocumentViewModel?
	@State var selectedPos: Int?
	@State var allowTextPredictions: Bool = true
	@State var preListScrollInput: String?
	@State var isHoverActive: Bool = true
	@State var latestCursorPT: CGPoint?
	
	init(_ controllerWrapper: ControllerWrapper, inNamespace: Namespace.ID, listOfSpaces: [NiDocumentViewModel]){
		self.predictableValues = listOfSpaces
		self.homeViewNameSpace = inNamespace
		self.controllerWrapper = controllerWrapper
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0.0){
			
			Spacer().frame(maxHeight: 150)
			
			PredictingTextField(
				predictableValues: self.$predictableValues,
				predictedValues: self.$predictedValues,
				textFieldInput: self.$textFieldInput,
				allowPredictions: self.$allowTextPredictions
			)
			.tint(.black)
			.padding(EdgeInsets(top: 0.0, leading: 20.0, bottom: 0.0, trailing: 20.0))
			.autocorrectionDisabled(false)
			.textFieldStyle(RoundedBorderTextFieldStyle())
			.disabled(textFieldDisabled)
			.onKeyPress(phases: .up){k in
				if ([.upArrow, .downArrow, .escape].contains(k.key)){
					return .handled
				}
				isHoverActive = false
				continueTyping()
				return .handled
			}
			.prefersDefaultFocus(in: homeViewNameSpace)

			
			List(lstToShow(), id: \.self, selection: $selection){ v in
				SuggestionRow(parent: self, data: v, selected: $selection, textFieldInput: $textFieldInput, isHoverActive: $isHoverActive)
				.listRowSeparatorTint(Color("transparent"))
				.selectionDisabled()
				.listRowInsets(EdgeInsets())
			}
			.accentColor(Color.transparent)
			.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
			.scrollContentBackground(.hidden)
			.background(Color.transparent)
			.onContinuousHover(coordinateSpace: .local){ phase in
				switch phase{
					case .active(let pt):
						if(latestCursorPT != pt){
							latestCursorPT = pt
							isHoverActive = true
						}
					case .ended:
						return
				}
			}
		}
		.onAppear {
			NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsEvent in
								
				if(nsEvent.type == .keyDown){
					handleKeyEvents(nsEvent: nsEvent)
				}
				return nsEvent
			}
		}
	}
	
	func handleKeyEvents(nsEvent: NSEvent){
		
		//TODO: come back and check if needed
		if(selection != nil && selectedPos == nil){
			updateSelectedPos(selectedRow: selection!)
		}
		
		if (nsEvent.keyCode == 125){	//down
			handleKeyDown()
		}else if (nsEvent.keyCode == 126){	//up
			handleKeyUp()
		}else if(nsEvent.keyCode == 53){	//ESC
			clearInput()
		}else if(nsEvent.keyCode == 36){	//enter
			switchToSpace()
		}
	}
	
	func updateSelectedPos(selectedRow: NiDocumentViewModel){
		selectedPos = lstToShow().firstIndex(of: selectedRow)
	}
	
	func lstToShow() -> Array<NiDocumentViewModel>{
		if(textFieldInput.isEmpty || (preListScrollInput != nil && preListScrollInput!.isEmpty)){
			return if(self.predictedValues.isEmpty){
					self.predictableValues
			   }else{
				   self.predictedValues
			   }
		}
		
		let newSpaceOption = if(preListScrollInput == nil) {
			NiDocumentViewModel(id: NewSpaceID, name: textFieldInput)
		} else {
			NiDocumentViewModel(id: NewSpaceID, name: preListScrollInput!)
		}
		
		if(self.predictedValues.isEmpty){
			return [newSpaceOption]
		}else{
			return self.predictedValues + [newSpaceOption]
		}
	}
	
	func handleKeyDown(){
		if(selection == nil){
			selectedPos = 0
			selection = lstToShow()[selectedPos!]
			
			enterSuggestionField()
		}else if(selectedPos! + 1 < lstToShow().count){
			selectedPos! += 1
			selection = lstToShow()[selectedPos!]
			self.textFieldInput = selection!.name
		}else{
			exitSuggestionField()
		}
	}
		
	func handleKeyUp(){
		if(selection != nil && selectedPos == 0){
			exitSuggestionField()
		} else if(selection != nil && 0 < selectedPos!){
			selectedPos! -= 1
			selection = lstToShow()[selectedPos!]
			textFieldInput = selection!.name
		} else if(selection == nil && selectedPos == nil){
			selectedPos = lstToShow().count - 1
			selection = lstToShow()[selectedPos!]
			
			enterSuggestionField()
		}
	}
	
	func enterSuggestionField(){
		//we are calling this function on mouse clicks when we already entered the selection field. That is why we check if we already entered it. If so we do NOT set the preListScrollInput
		if(allowTextPredictions){
			preListScrollInput = textFieldInput
		}
		allowTextPredictions = false
//		textFieldDisabled = true
		textFieldInput = selection!.name
	}
	
	func continueTyping(){
		selection = nil
		selectedPos = nil
		allowTextPredictions = true
		
		preListScrollInput = nil
	}
	
	func exitSuggestionField(){
		selection = nil
		selectedPos = nil
		
		textFieldInput = preListScrollInput ?? ""
//		textFieldDisabled = false
		allowTextPredictions = true
		
		preListScrollInput = nil
	}
	
	func clearInput(){
		
		if(preListScrollInput != nil){
			textFieldInput = preListScrollInput!
			preListScrollInput = nil
		}else if(textFieldInput.isEmpty){
			tryHideHomeView()
		}else{
			textFieldInput = ""
		}
		
		selection = nil
		selectedPos = nil
		allowTextPredictions = true
	}
	
	func tryHideHomeView(){
		controllerWrapper.hostingController?.tryHide()
	}
	
	func switchToSpace(){
		if (selection != nil && selection?.id != NewSpaceID){
			controllerWrapper.hostingController?.openExistingSpace(spaceId: selection!.id!, name: selection!.name)
		}else if(selection != nil && selection?.id == NewSpaceID){
			controllerWrapper.hostingController?.openNewSpace(name: selection!.name)
		}
	}
}

/*
 * MARK: - Suggestion Row
 */
struct SuggestionRow: View {
	
	private var data: NiDocumentViewModel
	@Binding var selected: NiDocumentViewModel?
	@Binding var textFieldInput: String
	@Binding var isHoverActive: Bool
	var parent: RightSide
	
	init(
		parent: RightSide,
		data: NiDocumentViewModel,
		selected: Binding<NiDocumentViewModel?>,
		textFieldInput: Binding<String>,
		isHoverActive: Binding<Bool>
	){
		self.parent = parent
		self.data = data
		self._selected = selected
		self._textFieldInput = textFieldInput
		self._isHoverActive = isHoverActive
	}
	
	var body: some View {
		HStack(alignment: .center){
			Image("SpaceIcon")
				.resizable()
				.frame(width:15, height: 15)
				.if(data.id == selected?.id){
					$0.foregroundColor(.intAerospaceOrange)
				} else: {
					$0.foregroundColor(.sandLight9)
				}
			Text(getSpaceTitle())
				.foregroundStyle(.sandDark8)
				.font(Font.custom("soehne-leicht", size: 12))
			Spacer()
		}
		.padding(5.0)
		.background(alignment: .center){
			if(data.id == selected?.id){
				BackgroundView()
			}
		}
		.frame(maxWidth: .infinity)
		.gesture(
			TapGesture(count: 2).onEnded {
				parent.switchToSpace()
			}
		)
		.onContinuousHover(coordinateSpace: .local){ phase in
			if(isHoverActive){
				switch phase{
					case .active(_):
						selected = data
						parent.enterSuggestionField()
						parent.updateSelectedPos(selectedRow: data)
					case .ended:
						parent.exitSuggestionField()
				}
			}
		}
	}
	
	func getSpaceTitle() -> String{
		
		if(data.id != NewSpaceID){
			return data.name
		}
		return "Create a space: " + data.name
	}
}

struct BackgroundView: View {
	var body: some View {
		Color.textSelectedBackground
			.clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5), style: .continuous))
	}
}

struct MenuBar: View {
	var body: some View {
		HStack{
			Spacer()
			Text("10:PM")
		}
	}
}

#Preview {
	HomeView(ControllerWrapper(), width:800.0, height: 450.0)
}

/*
 * MARK: - View extension
 */
extension View {
	
	/**
	 * Example:
	 *	var body: some view {
	 *		myView
	 *			.if(X) { $0.buttonStyle(.bordered) }
	 *	}
	 */
	@ViewBuilder
	func `if`<Transform: View>(
	  _ condition: Bool,
	  transform: (Self) -> Transform
	) -> some View {
	  if condition {
		transform(self)
	  } else {
		self
	  }
	}
	
	/**
	 * Example:
	 *	var body: some view {
	 *		myView
	 *			.if(X) { $0.buttonStyle(.bordered) } else: { $0.buttonStyle(.borderedProminent) }
	 *	}
	 */
	@ViewBuilder
	func `if`<TrueContent: View, FalseContent: View>(
	  _ condition: Bool,
	  if ifTransform: (Self) -> TrueContent,
	  else elseTransform: (Self) -> FalseContent
	) -> some View {
	  if condition {
		ifTransform(self)
	  } else {
		elseTransform(self)
	  }
	}
}
