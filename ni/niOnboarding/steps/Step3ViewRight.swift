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
					}
				}
			}
		}
	}
}

#Preview {
	Step3ViewRight()
		.frame(width: 900, height: 700)
}
