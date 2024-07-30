//
//  Legend.swift
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

struct Legend: View {
    @ObservedObject var data: ChartData
    @Binding var frame: CGRect
    @Binding var hideHorizontalLines: Bool
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    var specifier: String = "%.2f"
    let padding:CGFloat = 3

    var stepWidth: CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.points.count-1)
    }
    var stepHeight: CGFloat {
        let points = self.data.onlyPoints()
        if let min = points.min(), let max = points.max(), min != max {
            if (min < 0){
                return (frame.size.height-padding) / CGFloat(max - min)
            }else{
                return (frame.size.height-padding) / CGFloat(max - min)
            }
        }
        return 0
    }
    
    var min: CGFloat {
        let points = self.data.onlyPoints()
        return CGFloat(points.min() ?? 0)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading){
            ForEach((0...4), id: \.self) { height in
                HStack(alignment: .center){
                    Text("\(self.getYLegendSafe(height: height), specifier: specifier)").offset(x: 0, y: self.getYposition(height: height) )
                        .foregroundColor(Colors.LegendText)
                        .font(.caption)
                    self.line(atHeight: self.getYLegendSafe(height: height), width: self.frame.width)
                        .stroke(self.colorScheme == .dark ? Colors.LegendDarkColor : Colors.LegendColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5,height == 0 ? 0 : 10]))
                        .opacity((self.hideHorizontalLines && height != 0) ? 0 : 1)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeOut(duration: 0.2))
                        .clipped()
                }
               
            }
            
            // Add X-axis labels
            HStack(spacing: 0) {
                ForEach(0..<data.points.count, id: \.self) { index in
                    if index % (data.points.count / 5) == 0 {
                        Text(formatDate(index))
                            .font(.caption)
                            .frame(width: stepWidth * CGFloat(data.points.count / 5))
                    }
                }
            }
            .offset(y: frame.height + 10)
            
        }
    }
    
    func formatDate(_ index: Int) -> String {
        // Implement date formatting logic here
        return "Day \(index)"
    }
    
    func getYLegendSafe(height:Int)->CGFloat{
        if let legend = getYLegend() {
            return CGFloat(legend[height])
        }
        return 0
    }
    
    func getYposition(height: Int)-> CGFloat {
        if let legend = getYLegend() {
            return (self.frame.height-((CGFloat(legend[height]) - min)*self.stepHeight))-(self.frame.height/2)
        }
        return 0
       
    }
    
    func line(atHeight: CGFloat, width: CGFloat) -> Path {
        var hLine = Path()
        hLine.move(to: CGPoint(x:5, y: (atHeight-min)*stepHeight))
        hLine.addLine(to: CGPoint(x: width, y: (atHeight-min)*stepHeight))
        return hLine
    }
    
    func getYLegend() -> [Double]? {
        let points = self.data.onlyPoints()
        guard let max = points.max(), let min = points.min() else { return nil }
        let step = (max - min) / 4
        return (0...4).map { min + step * Double($0) }
    }

    func formatSubscriberCount(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", value / 1_000)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

struct Legend_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader{ geometry in
            Legend(data: ChartData(points: [0.2,0.4,1.4,4.5]), frame: .constant(geometry.frame(in: .local)), hideHorizontalLines: .constant(false))
        }.frame(width: 320, height: 200)
    }
}
