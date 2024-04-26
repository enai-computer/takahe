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
		}
		.frame(width: width, height: height)
		.clipShape(
			RoundedCornersShape(radius: 30.0, corners: [.bottomLeft, .bottomRight])
		)
		.shadow(color: .homeViewShadow, radius: 10.0, x: 2, y: 4)
	}
}

struct LeftSide: View {
	var body: some View {
		VStack{
			Spacer().frame(maxHeight: 229)
			Text("\(getWelcomeMessage()), \(NSUserName())")
				.font(.custom("Sohne-Kraftig", size: 28))
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
			
			Spacer().frame(maxHeight: 213)
			
			HStack(){
				Spacer(minLength: 12.5)
				PredictingTextField(
					predictableValues: self.$predictableValues,
					predictedValues: self.$predictedValues,
					textFieldInput: self.$textFieldInput,
					allowPredictions: self.$allowTextPredictions
				)
				.tint(.black)
				.padding(EdgeInsets(top: 20.0, leading: 28.0, bottom: 20.0, trailing: 20.0))
				.autocorrectionDisabled(false)
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
			}.background(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
			 .foregroundStyle(Color.sandLight1)
			 .frame(minHeight: 64)
			)
			.padding([.leading, .trailing], 60.0)
			.padding(.bottom, 20.0)
			
			List(lstToShow(), id: \.self, selection: $selection){ v in
				SuggestionRow(parent: self, data: v, selected: $selection, textFieldInput: $textFieldInput, isHoverActive: $isHoverActive)
				.listRowSeparatorTint(Color("transparent"))
				.selectionDisabled()
				.listRowInsets(EdgeInsets())
			}
			.accentColor(Color.transparent)
			.padding(EdgeInsets(top: 0.0, leading: 40.0, bottom: 0.0, trailing: 0.0))
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
			Spacer().frame(maxWidth: 8)
			Image("SpaceIcon")
				.resizable()
				.frame(width:18, height: 18)
				.if(data.id == selected?.id){
					$0.foregroundColor(.intAerospaceOrange)
				} else: {
					$0.foregroundColor(.sandLight9)
				}
				.padding([.trailing], 8.0)
			Text(getSpaceTitle())
				.foregroundStyle(.sandDark8)
				.font(.custom("Sohne-Buch", size: 18))
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
			TapGesture(count: 1).onEnded {
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
	HomeView(ControllerWrapper(), width:1600.0, height: 900.0)
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

// defines OptionSet, which corners to be rounded – same as UIRectCorner
struct RectCorner: OptionSet {
	
	let rawValue: Int
		
	static let topLeft = RectCorner(rawValue: 1 << 0)
	static let topRight = RectCorner(rawValue: 1 << 1)
	static let bottomRight = RectCorner(rawValue: 1 << 2)
	static let bottomLeft = RectCorner(rawValue: 1 << 3)
	
	static let allCorners: RectCorner = [.topLeft, topRight, .bottomLeft, .bottomRight]
}


// draws shape with specified rounded corners applying corner radius
struct RoundedCornersShape: Shape {
	
	var radius: CGFloat = .zero
	var corners: RectCorner = .allCorners

	func path(in rect: CGRect) -> Path {
		var path = Path()

		let p1 = CGPoint(x: rect.minX, y: corners.contains(.topLeft) ? rect.minY + radius  : rect.minY )
		let p2 = CGPoint(x: corners.contains(.topLeft) ? rect.minX + radius : rect.minX, y: rect.minY )

		let p3 = CGPoint(x: corners.contains(.topRight) ? rect.maxX - radius : rect.maxX, y: rect.minY )
		let p4 = CGPoint(x: rect.maxX, y: corners.contains(.topRight) ? rect.minY + radius  : rect.minY )

		let p5 = CGPoint(x: rect.maxX, y: corners.contains(.bottomRight) ? rect.maxY - radius : rect.maxY )
		let p6 = CGPoint(x: corners.contains(.bottomRight) ? rect.maxX - radius : rect.maxX, y: rect.maxY )

		let p7 = CGPoint(x: corners.contains(.bottomLeft) ? rect.minX + radius : rect.minX, y: rect.maxY )
		let p8 = CGPoint(x: rect.minX, y: corners.contains(.bottomLeft) ? rect.maxY - radius : rect.maxY )

		
		path.move(to: p1)
		path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.minY),
					tangent2End: p2,
					radius: radius)
		path.addLine(to: p3)
		path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.minY),
					tangent2End: p4,
					radius: radius)
		path.addLine(to: p5)
		path.addArc(tangent1End: CGPoint(x: rect.maxX, y: rect.maxY),
					tangent2End: p6,
					radius: radius)
		path.addLine(to: p7)
		path.addArc(tangent1End: CGPoint(x: rect.minX, y: rect.maxY),
					tangent2End: p8,
					radius: radius)
		path.closeSubpath()

		return path
	}
}

// View extension, to be used like modifier:
// SomeView().roundedCorners(radius: 20, corners: [.topLeft, .bottomRight])
extension View {
	func roundedCorners(radius: CGFloat, corners: RectCorner) -> some View {
		clipShape( RoundedCornersShape(radius: radius, corners: corners) )
	}
}
