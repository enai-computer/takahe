//
//  Step23ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI


struct Step23ViewLeft: View {
	@State private var text1Opacity: Double = 1.0
	@State private var text2Opacity: Double = 0.0
	@State private var showNewText: Bool = false
	let animationState: StepRunsAnimation
	
	init(_ animationState: StepRunsAnimation){
		self.animationState = animationState
	}
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 20.0){
				Spacer()
					.frame(width: 120.0)
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)

					Text("Computers are getting busier.")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundColor(.sand12)
						.opacity(text1Opacity)
					if showNewText {
						Spacer()
							.frame(height: 30.0)
						Text("So Enai gives you space(s)")
							.font(.custom("Sohne-Kraftig", size: 30))
							.foregroundColor(.sand12)
							.transition(.opacity)
						
						Spacer()
							.frame(height: 30.0)
						
						Text("To do anything you want \nwith no distractions.")
							.font(.custom("Sohne-Buch", size: 21))
							.foregroundColor(.sand12)
							.lineSpacing(3.5)
							.transition(.opacity)
						
						Text("Work on something, put it away,\ncome back anytime.")
							.font(.custom("Sohne-Buch", size: 21))
							.foregroundColor(.sand12)
							.lineSpacing(3.5)
							.transition(.opacity)
					}
					Spacer()
				}
				Spacer()
			}
		}.onChange(of: animationState.runFwdAnimation){
			runTransition()
		}
	}
	
	func runTransition() {
		withAnimation(.easeOut(duration: 1.0)) {
			if(showNewText){
				self.text1Opacity = 1.0
			}else{
				self.text1Opacity = 0.2
			}
			self.showNewText.toggle()
		}
	}
}

#Preview {
	Step23ViewLeft(StepRunsAnimation())
		.frame(width: 600, height: 700)
}
