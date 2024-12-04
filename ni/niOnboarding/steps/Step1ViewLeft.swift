//
//  Step1ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step1ViewLeft: View {
	
	var body: some View {
		GeometryReader { geometry in
			HStack(alignment: .top, spacing: 20.0){
				Spacer()
					.frame(width: 120.0)
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)
					Text("Welcome")
						.font(.custom("Sohne-Kraftig", size: 30))
						.contentMargins(.bottom, 45.0)
						.foregroundStyle(
							Color.sand12.shadow(
								.inner(color: .white, radius: 1.40, x: 0, y: 0)
							)
						)
					
					Text("Enai is a personal \ninternet computer.")
						.font(.custom("Sohne-Buch", size: 21))
						.contentMargins(.bottom, 33.0)
						.foregroundStyle(
							Color.sand12.shadow(
								.inner(color: .white, radius: 0.4, x: 0, y: 0)
							)
						)

					
					Text("To simplify your life and \ncare for your attention.")
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
	Step1ViewLeft()
		.frame(width: 600, height: 700)
}
