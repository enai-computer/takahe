//
//  Step23ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

@Observable
final class Step23RunAnimation{
	var runFwdAnimation: Bool = false
}

struct Step23ViewLeft: View, ViewAnimationProtocol {
	@State private var text1Opacity: Double = 1.0
	@State private var showNewText: Bool = false
	let animationState: Step23RunAnimation
	
	init(_ animationState: Step23RunAnimation){
		self.animationState = animationState
	}
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .center, spacing: 20.0){
				Spacer()
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)

					Text("Computers are getting busier.")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundColor(.sand12)
						.opacity(text1Opacity)
					if showNewText {
						Text("So Enai gives you space(s)")
							.font(.custom("Sohne-Kraftig", size: 30))
							.foregroundColor(.sand12)
						
						Text("To do anything you want \nwith no distractions.")
							.font(.custom("Sohne-Buch", size: 21))
							.foregroundColor(.sand12)
						
						Text("Work on something, put it away,\ncome back anytime.")
							.font(.custom("Sohne-Buch", size: 21))
							.foregroundColor(.sand12)
					}
					Spacer()
				}
				Spacer()
			}
		}.onChange(of: animationState.runFwdAnimation){
			_ = runFwdTransition()
		}
	}
	
	func runFwdTransition() -> Bool {
		if(self.showNewText){	//animation already ran
			return false
		}
		withAnimation(.easeOut(duration: 1.0)) {
			self.text1Opacity = 0.1
		}
		self.showNewText = true
		return true
	}
}

#Preview {
	Step23ViewLeft(Step23RunAnimation())
		.frame(width: 600, height: 700)
}


/*
 Text("Computers are getting busier.")
	 .font(.custom("Sohne-Buch", size: 21))
	 .foregroundColor(.sand12)
	 .opacity(0.5)
 
 Text("So Enai gives you space(s)")
	 .font(.custom("Sohne-Kraftig", size: 30))
	 .foregroundColor(.sand12)
 
 Text("To do anything you want \nwith no distractions.")
	 .font(.custom("Sohne-Buch", size: 21))
	 .foregroundColor(.sand12)
 
 Text("Work on something, put it away,\ncome back anytime.")
	 .font(.custom("Sohne-Buch", size: 21))
	 .foregroundColor(.sand12)
 */
