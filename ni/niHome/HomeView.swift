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

class ControllerWrapper{
	weak var hostingController: HomeViewController?
}

struct HomeView: View {
	
	var lstOfSpaces = DocumentTable.fetchListofDocs()
	let controllerWrapper: ControllerWrapper
	
	init(_ controllerWrapper: ControllerWrapper){
		self.controllerWrapper = controllerWrapper
	}
	
    var body: some View {
		VStack{
			HSplitView {
				LeftSide().background(Color.leftSideBackground)
				RightSide(controllerWrapper, listOfSpaces: lstOfSpaces)
					.background(Color.rightSideBackground)
			}
		}
	}
}

struct LeftSide: View {
	var body: some View {
		VStack{
			Text("\(getWelcomeMessage()), \(NSUserName())")
				.font(Font.custom("soehne-buch", size: 24))
				.foregroundStyle(.sandLight11)
			
		}.frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
	}
}


struct RightSide: View {
	let controllerWrapper: ControllerWrapper
	
	@State var textFieldInput: String = ""
	@State var predictableValues: Array<NiDocumentViewModel>
	@State var predictedValues: Array<NiDocumentViewModel> = []
	
	@State var selection: NiDocumentViewModel?
	@State var selectedPos: Int?
	@State var allowTextPredictions: Bool = true
	@State var preListScrollInput: String?
	
	init(_ controllerWrapper: ControllerWrapper, listOfSpaces: [NiDocumentViewModel]){
		self.predictableValues = listOfSpaces
		self.controllerWrapper = controllerWrapper
	}
	
	var body: some View {
		VStack(alignment: .leading){
			
			Spacer().frame(minHeight: 0.5)
			
			PredictingTextField(
				predictableValues: self.$predictableValues,
				predictedValues: self.$predictedValues,
				textFieldInput: self.$textFieldInput,
				allowPredictions: self.$allowTextPredictions
			)
			.autocorrectionDisabled(false)
			.textFieldStyle(RoundedBorderTextFieldStyle())

			List(lstToShow(), id: \.self, selection: $selection){ v in
				SuggestionRow(data: v, selected: $selection, textFieldInput: $textFieldInput)
				.listRowSeparatorTint(Color("transparent"))
			}
			.scrollContentBackground(.hidden)
			.background(Color.transparent)

		}
		.frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
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
			selectedPos = lstToShow().firstIndex(of: selection!)
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
	
	func lstToShow() -> Array<NiDocumentViewModel>{
		return if(self.predictedValues.isEmpty){
			self.predictableValues
		   }else{
			   self.predictedValues
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
		preListScrollInput = textFieldInput
		allowTextPredictions = false
		textFieldInput = selection!.name
	}
	
	func exitSuggestionField(){
		selection = nil
		selectedPos = nil
		
		textFieldInput = preListScrollInput ?? ""
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
		if (selection != nil){
			controllerWrapper.hostingController?.openExistingSpace(spaceId: selection!.id, name: selection!.name)
		}
	}
}


struct SuggestionRow: View {
	
	private var data: NiDocumentViewModel
	@Binding var selected: NiDocumentViewModel?
	@Binding var textFieldInput: String
	
	init(
		data: NiDocumentViewModel, 
		selected: Binding<NiDocumentViewModel?>,
		textFieldInput: Binding<String>
	){
		self.data = data
		self._selected = selected
		self._textFieldInput = textFieldInput
	}
	
	var body: some View {
		HStack(){
			Image(systemName: "square.2.stack.3d")
			Text(data.name)
				.foregroundStyle(.sandDark8)
				.font(Font.custom("soehne-leicht", size: 12))
			Spacer()
		}
		.background(alignment: .center){
			if(data.id == selected?.id){
				BackgroundView()
			}
		}
		.frame(maxWidth: .infinity)
	}
}

struct BackgroundView: View {
	var body: some View {
		Color.textSelectedBackground
			.cornerRadius(5.0)
	}
}

struct BackgroundView2: View {
	var body: some View {
		Color.transparent
			.cornerRadius(5.0)
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
    HomeView(ControllerWrapper())
}
