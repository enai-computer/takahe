//
//  HomeView.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import SwiftUI

let stdCorner = RectangleCornerRadii(
	topLeading: 5,
	bottomLeading: 5,
	bottomTrailing: 5,
	topTrailing: 5
)

struct HomeView: View {
	
	private var isShown = true
	var lstOfSpaces = DocumentTable.fetchListofDocs()
	
    var body: some View {
		VStack{
			HSplitView {
				LeftSide().background(Color.leftSideBackground)
				RightSide(listOfSpaces: lstOfSpaces)
					.background(Color.rightSideBackground)
			}
			if(!isShown){
				MenuBar()
			}
		}
	}
}

struct LeftSide: View {
	var body: some View {
		Text("\(getWelcomeMessage()), \(NSUserName())")
			.font(Font.custom("soehne-buch", size: 24))
			.foregroundStyle(.sandLight11)
			.frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct RightSide: View {
	@State var textFieldInput: String = ""
	@State var predictableValues: Array<NiDocumentViewModel>
	@State var predictedValues: Array<NiDocumentViewModel> = []
	
	@State var selection: NiDocumentViewModel?
	@State var selectedPos: Int?
	@State var allowTextPredictions: Bool = true
	@State var preListScrollInput: String?
	
	init(listOfSpaces: [NiDocumentViewModel]){
		self.predictableValues = listOfSpaces
	}
	
	func lstToShow() -> Array<NiDocumentViewModel>{
		return if(self.predictedValues.isEmpty){
			self.predictableValues
		   }else{
			   self.predictedValues
		   }
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
				SuggestionRow(data: v, selected: $selection)
				.listRowSeparatorTint(Color("transparent"))
			}
			.scrollContentBackground(.hidden)
			.background(Color.transparent)

		}
		.frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
		.onAppear {
			//TODO: clean this up!
				NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { nsevent in
					if(selectedPos == nil && selection != nil){
						//TODO: clean up:
						selectedPos = lstToShow().firstIndex(of: selection!)
					}
					
					if (nsevent.keyCode == 125){	//down
						if(selection == nil){
							selectedPos = 0
							selection = lstToShow()[selectedPos!]
							
							self.preListScrollInput = self.textFieldInput
							self.allowTextPredictions = false
							self.textFieldInput = selection!.name
						}else if(selectedPos! + 1 < lstToShow().count){
							selectedPos! += 1
							selection = lstToShow()[selectedPos!]
							self.textFieldInput = selection!.name
						}else{
							selection = nil
							selectedPos = nil
							self.allowTextPredictions = true
							self.textFieldInput = self.preListScrollInput!
						}
					}else if nsevent.keyCode == 126{	//up
						if(selection != nil && selectedPos == 0){
							selection = nil
							selectedPos = nil
							self.allowTextPredictions = true
							self.textFieldInput = self.preListScrollInput!
						} else if(selection != nil && 0 < selectedPos!){
							selectedPos! -= 1
							selection = lstToShow()[selectedPos!]
							self.textFieldInput = selection!.name
						} else if(selection == nil && selectedPos == nil){
							selectedPos = lstToShow().count - 1
							selection = lstToShow()[selectedPos!]
							
							self.preListScrollInput = self.textFieldInput
							self.allowTextPredictions = false
							self.textFieldInput = selection!.name
						}
					}
					return nsevent
				}
			}
	}
}


struct SuggestionRow: View {
	
	private var data: NiDocumentViewModel
	private let selected: Binding<NiDocumentViewModel?>
	
	init(data: NiDocumentViewModel, selected: Binding<NiDocumentViewModel?>){
		self.data = data
		self.selected = selected
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
//			Group{
				if(data.id == selected.wrappedValue?.id){
					BackgroundView()
				}else{
					
				}
//		    }
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
    HomeView()
}
