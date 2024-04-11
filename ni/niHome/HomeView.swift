//
//  HomeView.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import SwiftUI

struct HomeView: View {
	
	var lstOfSpaces = DocumentTable.fetchListofDocs()
	
    var body: some View {
		HSplitView {
			LeftSide().background(Color.leftSideBackground)
			RightSide(listOfSpaces: lstOfSpaces).background(Color.rightSideBackground)
		}
	}
}

struct LeftSide: View {
	var body: some View {
		Text("\(getWelcomeMessage()), \(NSUserName())")
			.frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
	}
}

struct RightSide: View {
	@State var textFieldInput: String = ""
	@State var predictableValues: Array<NiDocumentViewModel>
	@State var predictedValues: Array<NiDocumentViewModel> = []
	
	init(listOfSpaces: [NiDocumentViewModel]){
		self.predictableValues = listOfSpaces
	}
	
	var body: some View {
		//		Text("Right")
		//			.frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
	
		VStack(alignment: .leading){
			PredictingTextField(
				predictableValues: self.$predictableValues,
				predictedValues: self.$predictedValues,
				textFieldInput: self.$textFieldInput
			)
			.autocorrectionDisabled(false)
			.textFieldStyle(RoundedBorderTextFieldStyle())
			
			if(self.predictedValues.count == 0){
				ForEach(self.predictableValues, id: \.self){ value in
					SuggestionRow(data: value)
				}
			}else{
				ForEach(self.predictedValues, id: \.self){ value in
					SuggestionRow(data: value)
				}
			}

				}.frame(minWidth: 240, idealWidth: 320, maxWidth: .infinity, maxHeight: .infinity)
			}
	}


struct SuggestionRow: View {
	
	private var data: NiDocumentViewModel
	
	init(data: NiDocumentViewModel){
		self.data = data
	}
	
	var body: some View {
		Text(data.name)
	}
}

#Preview {
    HomeView()
}
