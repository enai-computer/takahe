//
//  Step1ViewLeft.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step1ViewLeft: View {
	
	var body: some View {
		HStack(alignment: .center, spacing: 20.0){
			Spacer()
			VStack(alignment: .leading, spacing: 20.0){
				Spacer()
				Text("Welcome")
					.font(.custom("Sohne-Kraftig", size: 30))
					.foregroundColor(.sand12)
				
				Text("Enai is a personal \ninternet computer.")
					.font(.custom("Sohne-Buch", size: 21))
					.foregroundColor(.sand12)
				
				Text("To simplify your life and \ncare for your attention.")
					.font(.custom("Sohne-Buch", size: 21))
					.foregroundColor(.sand12)
				Spacer()
			}
			Spacer()
		}
	}
}

#Preview {
	Step1ViewLeft()
}
