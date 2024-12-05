//
//  Step3ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI


struct Step3ViewLeft: View {
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 20.0){
				Spacer()
					.frame(width: 120.0)
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)
					
					Text("A canvas for every context")
						.font(.custom("Sohne-Buch", size: 30))
						.foregroundStyle(
							Color.sand12.shadow(
								.inner(color: .white, radius: 0.8, x: 0, y: 0)
							)
						)
						
					Spacer()
						.frame(height: 10.0)
					
					Text("Save and interact with everything. \nWebsites, apps, notes, docs, photos......")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundStyle(
							Color.sand12.shadow(
								.inner(color: .white, radius: 0.4, x: 0, y: 0)
							)
						)
						.lineSpacing(3.5)

					Spacer()
						.frame(height: 1.0)
					
					Text("And an AI personal assistant")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundStyle(
							Color.sand12.shadow(
								.inner(color: .white, radius: 0.4, x: 0, y: 0)
							)
						)
					Spacer()
				}
				Spacer()
			}
		}
	}
}

#Preview {
	Step3ViewLeft()
		.frame(width: 600, height: 700)
}
