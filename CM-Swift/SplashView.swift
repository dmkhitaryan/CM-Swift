//
//  SplashView.swift
//  CM-Swift
//
//  Created by David Mkhitaryan on 07/04/2023.
//

import SwiftUI

struct Background: View{
    var body: some View {
            Image("SplashBG")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
    }
}

struct SplashView: View {
    @State var isActive : Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.5

    // Customise your SplashScreen here
    var body: some View {
        let str2 = """
        App Design by:
        David Mkhitaryam (S3415732)
        Twan Vos (S3734870)
        Imme Huitema (S3447472)
        """
        if isActive {
            MainMenuView()
        } else {
            ZStack {
                Background()
                VStack {
                    VStack {
                        Image("SplashImage")
                            .resizable()
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                        Text("\(str2)")
                            .font(Font.custom("Baskerville-Bold", size: 18))
                            .foregroundColor(.white.opacity(0.80))
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 0.9
                            self.opacity = 1.00
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
