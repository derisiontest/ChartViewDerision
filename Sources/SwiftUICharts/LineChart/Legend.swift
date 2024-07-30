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
    var xAxisLabels: [String]
    var yAxisLabels: [String]

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
            ForEach(0..<yAxisLabels.count, id: \.self) { height in
                HStack(alignment: .center){
                    Text(yAxisLabels[height])
                        .offset(x: 0, y: self.getYposition(height: height))
                        .foregroundColor(Colors.LegendText)
                        .font(.caption)
                    self.line(atHeight: CGFloat(height) * stepHeight, width: self.frame.width)
                        .stroke(self.colorScheme == .dark ? Colors.LegendDarkColor : Colors.LegendColor, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [5,height == 0 ? 0 : 10]))
                        .opacity((self.hideHorizontalLines && height != 0) ? 0 : 1)
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .animation(.easeOut(duration: 0.2))
                        .clipped()
                }
            }
            
            // X-axis labels
            HStack(spacing: 0) {
                ForEach(0..<xAxisLabels.count, id: \.self) { index in
                    Text(xAxisLabels[index])
                        .font(.caption)
                        .frame(width: stepWidth * CGFloat(data.points.count / (xAxisLabels.count - 1)))
                }
            }
            .offset(y: frame.height + 10)
        }
    }
    
    func getYposition(height: Int) -> CGFloat {
        return (self.frame.height - (CGFloat(height) * stepHeight)) - (self.frame.height / 2)
    }
    
    func line(atHeight: CGFloat, width: CGFloat) -> Path {
        var hLine = Path()
        hLine.move(to: CGPoint(x:5, y: atHeight))
        hLine.addLine(to: CGPoint(x: width, y: atHeight))
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
            Legend(data: ChartData(points: [0.2,0.4,1.4,4.5]),
                   frame: .constant(geometry.frame(in: .local)),
                   hideHorizontalLines: .constant(false),
                   xAxisLabels: ["Day 1", "Day 7", "Day 14", "Day 21", "Day 30"],
                   yAxisLabels: ["0", "1K", "2K", "3K", "4K", "5K"])
        }.frame(width: 320, height: 200)
    }
}
