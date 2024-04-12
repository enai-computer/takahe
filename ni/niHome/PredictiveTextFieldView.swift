//
//  PredictiveTextFieldView.swift
//  ni
//
//  Created by Patrick Lukas on 11/4/24.
//

import SwiftUI

/// TextField capable of making predictions based on provided predictable values
struct PredictingTextField: View {
	
	/// All possible predictable values. Can be only one.
	@Binding var predictableValues: Array<NiDocumentViewModel>
	
	/// This returns the values that are being predicted based on the predictable values
	@Binding var predictedValues: Array<NiDocumentViewModel>
	
	/// Current input of the user in the TextField. This is Binded as perhaps there is the urge to alter this during live time. E.g. when a predicted value was selected and the input should be cleared
	@Binding var textFieldInput: String
	
	//in case the user interacts with the suggestions we do not want to update the list of suggestions
	@Binding var allowPredictions: Bool
	
	/// The time interval between predictions based on current input. Default is 0.1 second. I would not recommend setting this to low as it can be CPU heavy.
	@State var predictionInterval: Double?
	
	/// Placeholder in empty TextField
	var textFieldTitle: String?
	
	@State private var isBeingEdited: Bool = false
	
	init(predictableValues: Binding<Array<NiDocumentViewModel>>,
		 predictedValues: Binding<Array<NiDocumentViewModel>>,
		 textFieldInput: Binding<String>,
		 allowPredictions: Binding<Bool>,
		 textFieldTitle: String? = "",
		 predictionInterval: Double? = 0.1
	){
		
		self._predictableValues = predictableValues
		self._predictedValues = predictedValues
		self._textFieldInput = textFieldInput
		self._allowPredictions = allowPredictions
		
		self.textFieldTitle = textFieldTitle
		self.predictionInterval = predictionInterval
	}
	
	var body: some View {
		TextField(
			"What would you like to explore?",
			text: self.$textFieldInput,
			onEditingChanged: { editing in self.realTimePrediction(status: editing)},
			onCommit: { self.makePrediction()}
		)	//TODO: update onCommit here
		.font(Font.custom("soehne-Leicht", size: 12))
		
	}
	
	/// Schedules prediction based on interval and only a if input is being made
	private func realTimePrediction(status: Bool) {
		self.isBeingEdited = status
		if status == true {
			Timer.scheduledTimer(withTimeInterval: self.predictionInterval ?? 1, repeats: true) { timer in
				
				if(allowPredictions){
					self.makePrediction()
				}

				
				if self.isBeingEdited == false {
					timer.invalidate()
				}
			}
		}
	}
	
	/// Capitalizes the first letter of a String
	private func capitalizeFirstLetter(smallString: String) -> String {
		return smallString.prefix(1).capitalized + smallString.dropFirst()
	}
	
	/// Makes prediciton based on current input
	private func makePrediction() {
		self.predictedValues = []
		if !self.textFieldInput.isEmpty{
			for value in self.predictableValues {
				if self.textFieldInput.split(separator: " ").count > 1 {
					self.makeMultiPrediction(value: value)
				}else {
					if value.name.lowercased().contains(self.textFieldInput.lowercased())
//						 || value.name.contains(self.capitalizeFirstLetter(smallString: self.textFieldInput))
					{
						if !self.predictedValues.contains(value) {
							self.predictedValues.append(value)
						}
					}
				}
			}
		}
	}
	
	/// Makes predictions if the input String is splittable
	private func makeMultiPrediction(value: NiDocumentViewModel) {
		for subString in self.textFieldInput.split(separator: " ") {
			if value.name.contains(String(subString)) || value.name.contains(self.capitalizeFirstLetter(smallString: String(subString))){
				if !self.predictedValues.contains(value) {
					self.predictedValues.append(value)
				}
			}
		}
	}
}
