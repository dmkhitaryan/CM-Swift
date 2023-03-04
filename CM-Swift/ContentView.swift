//
//  ContentView.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 01/03/2023.
//

import SwiftUI

struct CardView: View {
    let number: Int
    
    var body: some View {
        Text("\(number)")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: 50, height: 80)
            .background(Color.blue)
            .cornerRadius(10)
    }
}

struct TheMindView: View {
    let deck: [Int]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(deck, id: \.self) { number in
                    CardView(number: number).aspectRatio(2/3, contentMode: .fit)
                }
            }.padding(.horizontal)
            Spacer()
        }
    }
}

struct ContentView: View {
    let deck: [Int] = Array(1...10).shuffled()
    
    var body: some View {
        TheMindView(deck: deck)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


