//
//  ContentView.swift
//  FlipTest
//
//  Created by yogox on 2020/08/05.
//  Copyright © 2020 Yogox Galaxy. All rights reserved.
//

import SwiftUI

struct FlippingView: View {
   
   @State private var flipped = false
   @State private var angle:Double = 0
   
   var body: some View {
       
       return VStack {
           Spacer()
           
           ZStack() {
               FrontCard().opacity(flipped ? 0.0 : 1.0)
               BackCard().opacity(flipped ? 1.0 : 0.0)
           }
               .modifier(FlipEffect(flipped: $flipped, angle: angle, axis: (x: 0, y: 1)))
           .onTapGesture {
               withAnimation(Animation.spring()) {
                   self.angle += 180
               }
               withAnimation(nil) {
                   if self.angle >= 360 {
                       self.angle = self.angle.truncatingRemainder(dividingBy: 360)
                   }
               }
           }
           Spacer()
       }
   }
}

struct FlipEffect: GeometryEffect {
   
   var animatableData: Double {
       get { angle }
       set { angle = newValue }
   }
   
   @Binding var flipped: Bool
   var angle: Double
   let axis: (x: CGFloat, y: CGFloat)
   
   func effectValue(size: CGSize) -> ProjectionTransform {
       
       DispatchQueue.main.async {
           self.flipped = self.angle >= 90 && self.angle < 270
       }
       
       let tweakedAngle = flipped ? -180 + angle : angle
       let a = CGFloat(Angle(degrees: tweakedAngle).radians)
       
       var transform3d = CATransform3DIdentity;
       transform3d.m34 = -1/max(size.width, size.height)
       
       transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
       transform3d = CATransform3DTranslate(transform3d, -size.width/2.0, -size.height/2.0, 0)
       
       let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width/2.0, y: size.height / 2.0))
       
       return ProjectionTransform(transform3d).concatenating(affineTransform)
   }
}

struct FrontCard : View {
   var body: some View {
       Text("Front side/表面").padding(5).frame(width: 300, height: 175, alignment: .center).background(Color.blue)
   }
}

struct BackCard : View {
   var body: some View {
       Text("Back side/裏面").padding(5).frame(width: 300, height: 175).background(Color.red)
   }
}

struct ContentView: View {
   var body: some View {
       FlippingView()
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
       ContentView()
   }
}
