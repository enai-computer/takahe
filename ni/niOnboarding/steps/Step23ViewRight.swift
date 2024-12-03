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
			Grid(){
				Spacer()
				
				GridRow{
					if(ranAnimation){
						Text("Trip to Korea")
							.font(.custom("Sohne-Kraftig", size: 21))
							.foregroundStyle(.birkin)
							.transition(.opacity)
					}
					Image("messyGroup1")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.frame(width: geometry.size.width * 0.4)
				}
				if(ranAnimation){
					Line()
						.stroke(style: StrokeStyle(lineWidth: 2.0, dash: [6]))
						.frame(width: geometry.size.width * 0.2, height: 4.0)
						.foregroundStyle(.birkin)
						.transition(.opacity)
				}
				
				GridRow{
					if(ranAnimation){
						Text("Term paper")
							.font(.custom("Sohne-Kraftig", size: 21))
							.foregroundStyle(.birkin)
							.transition(.opacity)
					}
					VStack(spacing: 0) {
						Image("messyGroup2")
							.resizable()
							.aspectRatio(nil, contentMode: .fit)
							.frame(width: geometry.size.width * 0.4)
						if(ranAnimation){
							Line()
								.stroke(style: StrokeStyle(lineWidth: 2.0, dash: [6]))
//								.frame(width: geometry.size.width * 0.2, height: 4.0)
								.foregroundStyle(.birkin)
								.transition(.opacity)
						}
					}
				}
					
					

				
				GridRow{
					if(ranAnimation){
						Text("Yoga teacher training")
						   .font(.custom("Sohne-Kraftig", size: 21))
						   .foregroundStyle(.birkin)
						   .transition(.opacity)
					}
					Image("messyGroup3")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.frame(width: geometry.size.width * 0.3)
						.offset(group3Offset ?? CGSize(
							width: -geometry.size.width * 0.07,
							height: -geometry.size.height * 0.08
						))
				}

				Spacer()
			}.frame(width: geometry.size.width)
		}.onChange(of: animationState.runFwdAnimation){
			runTransition()
		}
	}
	
	func runTransition() {
		rootVStackAligmnent = .leading
		withAnimation{
			ranAnimation.toggle()
		}
		group3Offset = CGSizeZero
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
	Step23ViewRight(StepRunsAnimation(), ranAnimation: true)
		.frame(width: 900, height: 700)
}
