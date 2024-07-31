//
//  LineView.swift Test
//  LineChart
//
//  Created by András Samu on 2019. 09. 02..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct LineView: View {
    @ObservedObject var data: ChartData
    public var title: String?
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var valueSpecifier: String
    public var legendSpecifier: String
    
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @State private var showLegend = false
    @State private var dragLocation:CGPoint = .zero
    @State private var indicatorLocation:CGPoint = .zero
    @State private var closestPoint: CGPoint = .zero
    @State private var opacity:Double = 0
    @State private var currentDataNumber: Double = 0
    @State private var hideHorizontalLines: Bool = false
    public var xAxisLabels: [String]
    public var yAxisLabels: [String]
    @State private var currentDataLabel: String = ""
    @State private var currentDataIndex: Int = 0
    private var overallMinDataValue: Double
    private var overallMaxDataValue: Double
    public var yAxisDivisions: Int
    public var lineColor: Color
    public var gradientColor: GradientColor
    public var visibleXAxisLabels: [String]
    public var indicatorSuffix: String
    public var xAxisTitle: String
    public var yAxisTitle: String
    private let dateFormatter: DateFormatter

    public init(data: [Double],
                title: String? = nil,
                legend: String? = nil,
                style: ChartStyle = Styles.lineChartStyleOne,
                valueSpecifier: String = "%.1f",
                legendSpecifier: String = "%.2f",
                xAxisLabels: [String],
                visibleXAxisLabels: [String],
                yAxisLabels: [String],
                yAxisDivisions: Int = 4,
                lineColor: Color = .blue,
                gradientColor: GradientColor? = nil,
                indicatorSuffix: String = "Subscribers",
                xAxisTitle: String = "Last 30 Days",
                yAxisTitle: String = "Subscribers") {
        
        // Combine xAxisLabels and data into tuples
        let dataPoints = Array(zip(xAxisLabels, data))
        self.data = ChartData(values: dataPoints)
        
        self.title = title
        self.legend = legend
        self.style = style
        self.valueSpecifier = valueSpecifier
        self.legendSpecifier = legendSpecifier
        self.darkModeStyle = style.darkModeStyle ?? Styles.lineViewDarkMode
        self.xAxisLabels = xAxisLabels
        self.visibleXAxisLabels = visibleXAxisLabels
        self.yAxisLabels = yAxisLabels
        self._currentDataNumber = State(initialValue: data.first ?? 0.0)
        
        self.overallMinDataValue = data.min() ?? 0
        self.overallMaxDataValue = data.max() ?? 0
        self.yAxisDivisions = yAxisDivisions
        self.lineColor = lineColor
        self.gradientColor = gradientColor ?? style.gradientColor
        self.indicatorSuffix = indicatorSuffix
        self.xAxisTitle = xAxisTitle
        self.yAxisTitle = yAxisTitle
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "d MMM"  // Changed to match the format of xAxisLabels
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 8) {
                if let title = self.title {
                    Text(title)
                        .font(.title)
                        .bold()
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                }
                if let legend = self.legend {
                    Text(legend)
                        .font(.callout)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                }
                
                HStack(alignment: .center, spacing: 0) {
                    // Y-axis title
                    /*Text(yAxisTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(Angle(degrees: -90))
                        .padding(0)
                     */
                    
                    ZStack {
                        HStack(spacing: 0) {
                            // Y-axis labels
                            VStack(alignment: .trailing, spacing: 0) {
                                ForEach(0..<self.getYAxisLabels().count, id: \.self) { index in
                                    Text(self.getYAxisLabels()[index])
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(height: (geometry.size.height - 40) / CGFloat(self.getYAxisLabels().count - 1))
                                    if index < self.getYAxisLabels().count - 1 {
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                            .frame(width: 40)
                            .padding(.leading, 0)
                            
                            // Main chart area
                            ZStack {
                                // Horizontal lines
                                VStack(spacing: 0) {
                                    ForEach(0..<self.getYAxisLabels().count, id: \.self) { index in
                                        GeometryReader { geometry in
                                            Path { path in
                                                path.move(to: CGPoint(x: 0, y: 0.5))
                                                path.addLine(to: CGPoint(x: geometry.size.width, y: 0.5))
                                            }
                                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                                            .foregroundColor(Color.gray.opacity(0.2))
                                        }
                                        .frame(height: 1)
                                        if index < self.getYAxisLabels().count - 1 {
                                            Spacer(minLength: 0)
                                        }
                                    }
                                }
                                
                                Line(data: self.data,
                                     frame: .constant(CGRect(x: 0, y: 0, width: geometry.size.width - 60, height: geometry.size.height - 40)),
                                     touchLocation: self.$indicatorLocation,
                                     showIndicator: self.$hideHorizontalLines,
                                     minDataValue: .constant(data.points.map { $0.1 }.min() ?? overallMinDataValue),
                                     maxDataValue: .constant(data.points.map { $0.1 }.max() ?? overallMaxDataValue),
                                     currentIndex: self.$currentDataIndex,
                                     showBackground: false,
                                     gradient: self.gradientColor,
                                     valueSpecifier: self.valueSpecifier,
                                     indicatorSuffix: self.indicatorSuffix,
                                     dateFormatter: self.dateFormatter)
                            }
                        }
                    }
                    .frame(height: geometry.size.height - 40)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    // X-axis labels
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(visibleXAxisLabels.indices, id: \.self) { index in
                            Text(visibleXAxisLabels[index])
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: (geometry.size.width - 40) / CGFloat(visibleXAxisLabels.count))
                        }
                    }
                    .padding(.leading, 40)  // Align with the chart area
                    .frame(height: 20)
                    .fixedSize(horizontal: false, vertical: true)
                    
                    /*
                    
                    // X-axis title
                    Text(xAxisTitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 0)
                     
                */
                }
            }
            .padding(.horizontal, 0)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let chartFrame = CGRect(x: 40, y: 0, width: geometry.size.width - 60, height: geometry.size.height - 30)
                    let touchLocation = CGPoint(x: value.location.x - 40, y: value.location.y - 30)
                    self.indicatorLocation = CGPoint(x: min(max(touchLocation.x, 0), chartFrame.width), y: touchLocation.y)
                    self.hideHorizontalLines = true
                    self.showLegend = true
                    self.currentDataIndex = self.getDataIndex(touchLocation: touchLocation, width: chartFrame.width)
                    self.currentDataNumber = self.data.points[self.currentDataIndex].1
                }
                .onEnded { _ in
                    self.hideHorizontalLines = false
                    self.showLegend = false
                }
            )
        }
    }
    
    private func getDataIndex(touchLocation: CGPoint, width: CGFloat) -> Int {
        let points = self.data.points
        let stepWidth = width / CGFloat(points.count - 1)
        let index = Int(round(touchLocation.x / stepWidth))
        return max(0, min(index, points.count - 1))
    }
    
    private func getYAxisLabels() -> [String] {
        let dataMin = 0.0
        let dataMax = (data.points.map { $0.1 }.max() ?? overallMaxDataValue) * 1.08 // Add 5% padding
        let range = dataMax - dataMin
        let step = range / Double(yAxisDivisions)
        
        return (0...yAxisDivisions).reversed().map { index in
            let value = dataMin + (step * Double(index))
            return formatSubscriberCount(value)
        }
    }

    private func formatSubscriberCount(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", value / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.0fK", value / 1_000)
        } else {
            return String(format: "%.0f", value)
        }
    }
    
    func getClosestDataPoint(toPoint: CGPoint, width: CGFloat, height: CGFloat) -> CGPoint {
        let points = self.data.points
        let stepWidth: CGFloat = width / CGFloat(points.count-1)
        let stepHeight: CGFloat = height / CGFloat(points.map { $0.1 }.max()! + points.map { $0.1 }.min()!)
        
        let index:Int = Int(floor((toPoint.x-15)/stepWidth))
        if (index >= 0 && index < points.count){
            self.currentDataIndex = index
            self.currentDataNumber = points[index].1
            self.currentDataLabel = points[index].0
            return CGPoint(x: CGFloat(index)*stepWidth, y: CGFloat(points[index].1)*stepHeight)
        }
        return .zero
    }
}

struct IndicatorPoint: View {
    var data: [(String, Double)]
    var index: Int
    var valueSpecifier: String
    var indicatorSuffix: String
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(formatNumber(data[index].1))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(indicatorSuffix)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                Text(formatDateWithYear(data[index].0))
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.8))
            .cornerRadius(8)
            .offset(y: -45)
            
            ZStack {
                Circle()
                    .fill(Colors.IndicatorKnob)
                Circle()
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 4))
            }
            .frame(width: 14, height: 14)
            .offset(y: -12)
        }
        .rotationEffect(.degrees(180))
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
    
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? ""
    }
    
    private func formatDateWithYear(_ dateString: String) -> String {
        let components = dateString.components(separatedBy: " ")
        if components.count >= 3 {
            return components.joined(separator: " ")
        }
        print("Debug: Year not found in date string: \(dateString)")
        return dateString
    }
}


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

public struct Line: View {
    @ObservedObject var data: ChartData
    @Binding var frame: CGRect
    @Binding var touchLocation: CGPoint
    @Binding var showIndicator: Bool
    @Binding var minDataValue: Double?
    @Binding var maxDataValue: Double?
    @State private var showFull: Bool = false
    @State var showBackground: Bool = true
    @State private var currentValue: Double = 0
    @Binding var currentIndex: Int  // Add this line
    var dateFormatter: DateFormatter
    var indicatorSuffix: String
    var gradient: GradientColor = GradientColor(start: Colors.GradientPurple, end: Colors.GradientNeonBlue)
    var index:Int = 0
    let padding:CGFloat = 30
    var curvedLines: Bool = true
    var stepWidth: CGFloat {
        if data.points.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.points.count-1)
    }
    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data.onlyPoints()
        if let minValue = minDataValue, let maxValue = maxDataValue {
            min = minValue
            max = maxValue
        } else if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = 0 // Start from 0
            max = maxPoint * 1.05 // Add 5% padding to the top
        } else {
            return 0
        }
        if let min = min, let max = max, min != max {
            return (frame.height - padding) / CGFloat(max - min)
        }
        return 0
    }
    var path: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue ?? 0) : Path.linePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }

    var closedPath: Path {
        let points = self.data.onlyPoints()
        return curvedLines ? Path.quadClosedCurvedPathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight), globalOffset: minDataValue ?? 0) : Path.closedLinePathWithPoints(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }


    
    var valueSpecifier: String
    
    // Update the initializer to include valueSpecifier
    public init(data: ChartData,
                frame: Binding<CGRect>,
                touchLocation: Binding<CGPoint>,
                showIndicator: Binding<Bool>,
                minDataValue: Binding<Double?>,
                maxDataValue: Binding<Double?>,
                currentIndex: Binding<Int>,
                showBackground: Bool = true,
                gradient: GradientColor = GradientColor(start: Colors.GradientPurple, end: Colors.GradientNeonBlue),
                index: Int = 0,
                curvedLines: Bool = true,
                valueSpecifier: String,
                indicatorSuffix: String,
                dateFormatter: DateFormatter) {

        self.data = data
        self._frame = frame
        self._touchLocation = touchLocation
        self._showIndicator = showIndicator
        self._minDataValue = minDataValue
        self._maxDataValue = maxDataValue
        self._currentIndex = currentIndex
        self.showBackground = showBackground
        self.gradient = gradient
        self.index = index
        self.curvedLines = curvedLines
        self.valueSpecifier = valueSpecifier
        self.indicatorSuffix = indicatorSuffix
        self.dateFormatter = dateFormatter
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                if(self.showBackground){
                    self.closedPath
                        .fill(LinearGradient(gradient: Gradient(colors: [Colors.GradientUpperBlue, .white]), startPoint: .bottom, endPoint: .top))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
                self.path
                    .stroke(LinearGradient(gradient: gradient.getGradient(), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                    .rotationEffect(.degrees(180), anchor: .center)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                
                // Cursor
                if(self.showIndicator) {
                    IndicatorPoint(data: self.data.points,
                                   index: self.currentIndex,
                                   valueSpecifier: self.valueSpecifier,
                                   indicatorSuffix: self.indicatorSuffix)
                        .position(self.getClosestPointOnPath(touchLocation: self.touchLocation))
                        .rotationEffect(.degrees(180), anchor: .center)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                }
            }
        }
    }
    
    func getClosestPointOnPath(touchLocation: CGPoint) -> CGPoint {
        let closest = self.path.point(to: touchLocation.x)
        let closestPoint = self.getDataPoint(touchLocation: touchLocation)
        self.currentIndex = closestPoint.0
        return closest
    }
    
    func getDataPoint(touchLocation: CGPoint) -> (Int, Double) {
        let points = self.data.onlyPoints()
        let stepWidth: CGFloat = self.frame.size.width / CGFloat(points.count-1)
        let index: Int = Int(round((touchLocation.x)/stepWidth))
        if (index >= 0 && index < points.count){
            return (index, points[index])
        }
        return (0, 0)
    }
}


struct LineView_Previews: PreviewProvider {
    static func generateTestData() -> [Double] {
        var data: [Double] = []
        let startValue: Double = 10_000
        let peakValue: Double = 2_000_000
        let totalDays = 30
        let growthDays = 24
        let dropDay = 25
        let riseDays = 5

        // Calculate growth rate for the first 24 days
        let growthRate = pow(peakValue / startValue, 1.0 / Double(growthDays - 1))
        
        // Growth phase (24 days)
        for i in 0..<growthDays {
            let value = startValue * pow(growthRate, Double(i))
            data.append(value)
        }
        
        // 30% drop (1 day)
        let dropValue = data.last! * 0.7
        data.append(dropValue)
        
        // 20% climb over 5 days
        let targetValue = dropValue * 1.2
        let riseRate = pow(targetValue / dropValue, 1.0 / Double(riseDays))
        for i in 1...riseDays {
            let value = dropValue * pow(riseRate, Double(i))
            data.append(value)
        }
        
        return data
    }
    
    static var previews: some View {
        Group {
            GeometryReader { geometry in
                LineView(data: generateTestData(),
                         style: Styles.lineChartStyleOne,
                         valueSpecifier: "%.0f",
                         legendSpecifier: "%.0f",
                         xAxisLabels: generateDateLabels(),
                         visibleXAxisLabels: generateVisibleDateLabels(),
                         yAxisLabels: [],
                         yAxisDivisions: 5,
                         lineColor: .blue,
                         gradientColor: GradientColor(start: .blue, end: .purple),
                         indicatorSuffix: "Members")
            }
            .previewLayout(.sizeThatFits)
            .frame(height: 400)
            .padding(0)
            .background(Color.white)
        }
        .padding(0)
    }

    static func generateDateLabels() -> [String] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        
        return (0..<30).map { index in
            let date = calendar.date(byAdding: .day, value: index, to: startDate)!
            return formatDate(date, includeYear: true)
        }
    }

    static func generateVisibleDateLabels() -> [String] {
        let labels = generateDateLabels().map { stripYearFromDate($0) }
        let strideValue = max(1, labels.count / 5)
        return Array(stride(from: 0, to: labels.count, by: strideValue)).map { labels[$0] }
    }

    static func formatDate(_ date: Date, includeYear: Bool = false) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = includeYear ? "d MMM yyyy" : "d MMM"
        return formatter.string(from: date)
    }

    static func stripYearFromDate(_ dateString: String) -> String {
        let components = dateString.components(separatedBy: " ")
        if components.count >= 2 {
            return components[0] + " " + components[1]
        }
        print("Debug: Unable to strip year from date string: \(dateString)")
        return dateString
    }
}
