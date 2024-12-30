//
//  AboutView.swift
//  Solstice
//
//  Created by Milind Contractor on 30/12/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            HStack {
                Image("solstice")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 125)
                    .padding()
                
                VStack {
                    HStack {
                        Text("Solstice")
                            .font(.custom("Playfair Display", size: 36))
                            .italic()
                        Spacer()
                    }
                    HStack {
                        Text("_Nebula_ v1.0.1")
                            .font(.custom("Playfair Display", size: 20))
                        Spacer()
                    }
                    .padding(.bottom)
                    HStack {
                        Text("Made with ❤️ by advaitconty")
                            .font(.custom("Crimson Pro", size: 17))
                        Spacer()
                    }
                }
            }
            
            Text("For updates, check the [Solstice GitHub](https://www.github.com/contyadvait/solstice) out!")
                .font(.custom("Crimson Pro", size: 18))
            Text("Auto updating is coming part of Solstice \"Quasar\"!")
                .font(.custom("Crimson Pro", size: 18))
        }
        .frame(width: 525, height: 300)
        .padding()
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
