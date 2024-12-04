//
//  Step23ViewRight.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step23ViewRight: View {
	let animationState: StepRunsAnimation
	
	@State var rootVStackAligmnent: HorizontalAlignment = .center
	@State var ranAnimation: Bool
	@State var blendIn: Float = 0.0
	@State var group3Offset: CGSize? = nil
	
	init(_ animationState: StepRunsAnimation, ranAnimation: Bool = false){
		self.animationState = animationState
		self.ranAnimation = ranAnimation
	}
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .center){
				Spacer()
					.frame(width:100.0)
				if(ranAnimation){
					VStack(alignment: .trailing){
						Spacer()
							.frame(height: geometry.size.height * 0.1)
						Text("Trip to Korea")
							.font(.custom("Sohne-Kraftig", size: 21))
							.foregroundStyle(.sand12)
							.transition(.opacity)
						
						Spacer()
							.frame(height: geometry.size.height * 0.3)
						
						Text("Term paper")
							.font(.custom("Sohne-Kraftig", size: 21))
							.foregroundStyle(.sand12)
							.transition(.opacity)
						
						Spacer()
							.frame(height: geometry.size.height * 0.3)
						
						Text("Self-Improvement")
						   .font(.custom("Sohne-Kraftig", size: 21))
						   .foregroundStyle(.sand12)
						   .transition(.opacity)
						
						Spacer()
							.frame(height: geometry.size.height * 0.1)
					}.frame(width: 270.0)
				}else{
					Spacer()
						.frame(width: 270.0)
				}

				Spacer()
					.frame(width:60.0)

				VStack{
					Spacer()
					Image("messyGroup1")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.frame(width: geometry.size.width * 0.35)
						.offset(group3Offset ?? CGSize(
							width: 0,
							height: geometry.size.height * 0.01
						))
					
					if(ranAnimation){
						Spacer()
						Line()
							.stroke(style: StrokeStyle(lineWidth: 1.0, dash: [6]))
							.frame(width: geometry.size.width * 0.25, height: 4.0)
							.foregroundStyle(.birkin)
							.transition(.opacity)
						Spacer()
					}
					
					Image("messyGroup2")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.frame(width: geometry.size.width * 0.35)
					
					if(ranAnimation){
						Spacer()
						Line()
							.stroke(style: StrokeStyle(lineWidth: 1.0, dash: [6]))
							.frame(width: geometry.size.width * 0.25, height: 4.0)
							.foregroundStyle(.birkin)
							.transition(.opacity)
						Spacer()
					}
					
					Image("messyGroup3")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.frame(width: geometry.size.width * 0.25)
						.offset(group3Offset ?? CGSize(
							width: 0,
							height: -geometry.size.height * 0.08
						))
					
					Spacer()
				}
				
				Spacer()
					.frame(width: 200.0)
				
			}.frame(width: geometry.size.width)
		}.onChange(of: animationState.runFwdAnimation){
			runTransition()
		}
	}
	
	func runTransition() {
		rootVStackAligmnent = .leading
		withAnimation{
			ranAnimation.toggle()
			group3Offset = CGSizeZero
		}
		return
	}
}

struct Line: Shape {
	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: CGPoint(x: 0, y: 0))
		path.addLine(to: CGPoint(x: rect.width, y: 0))
		return path
	}
}

#Preview {
	Step23ViewRight(StepRunsAnimation(), ranAnimation: false)
		.frame(width: 900, height: 900)
}
