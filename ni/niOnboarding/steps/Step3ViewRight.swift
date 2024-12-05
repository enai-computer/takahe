//
//  Step3ViewRight.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step3ViewRight: View {
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .center) {
				VStack(alignment: .trailing){
					Spacer()
						.frame(height: 100)
					HStack(){
						Spacer()
							.frame(height: 100)
						Image("step3RightSideImg")
							.resizable()
							.aspectRatio(nil, contentMode: .fill)
							.shadow(color: Color(red: 0.11, green: 0.1, blue: 0.1).opacity(0.15), radius: 7.5, x: 5, y: 5)
							.shadow(color: Color(red: 0.56, green: 0.56, blue: 0.55).opacity(0.8), radius: 1, x: 0, y: 0)
					}
				}
			}
		}
	}
}

#Preview {
	Step3ViewRight()
		.frame(width: 900, height: 900)
}
