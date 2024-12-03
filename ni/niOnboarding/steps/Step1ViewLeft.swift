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
			HStack(alignment: .center, spacing: 20.0){
				Spacer()
				VStack(alignment: .leading, spacing: 20.0){
					Spacer()
						.frame(height: geometry.size.height * 0.4)
					Text("Welcome")
						.font(.custom("Sohne-Kraftig", size: 30))
						.foregroundColor(.sand12)
						.contentMargins(.bottom, 45.0)
					
					Text("Enai is a personal \ninternet computer.")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundColor(.sand12)
						.contentMargins(.bottom, 33.0)
					
					Text("To simplify your life and \ncare for your attention.")
						.font(.custom("Sohne-Buch", size: 21))
						.foregroundColor(.sand12)
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
