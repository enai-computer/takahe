//
//  Step5ViewRight.swift
//  Enai
//
//  Created by Patrick Lukas on 28/11/24.
//

import SwiftUI

struct Step5ViewRight: View {
	
	@State var topImgWidth: CGFloat = 0.0
	
	var body: some View {
		GeometryReader { geometry in
			
			HStack(alignment: .center){
				Spacer()
				VStack(alignment: .center){
					Spacer()
					Image("step5RightSideImg")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.frame(width: geometry.size.width * 0.8)
					Image("step5RightSideImgBottom")
						.resizable()
						.aspectRatio(nil, contentMode: .fit)
						.frame(width: geometry.size.width * 0.5)
					Spacer()
				}
				Spacer()
			}
		}
	}
}

#Preview {
	Step5ViewRight()
		.frame(width: 900, height: 900)
}
