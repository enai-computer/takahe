//
//  Step3ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 29/11/24.
//

import SwiftUI

struct Step3ViewLeft: View {
	
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
