import SwiftUI

struct RulerView: View {
    @AppStorage("rulerWidthRatio") private var rulerWidthRatio = 0.33
    @AppStorage("zeroOffsetMM") private var zeroOffsetMM = 0.0
    @AppStorage("tickLength") private var tickLength = 18.0
    @AppStorage("tickWidth") private var tickWidth = 2.0
    @AppStorage("numberFontSize") private var numberFontSize = 28.0
    @AppStorage("fontDesign") private var fontDesign = "rounded"
    @AppStorage("fontWeight") private var fontWeight = "bold"
    @AppStorage("showZeroSlider") private var showZeroSlider = true
    @AppStorage("mmSpacing") private var mmSpacing = 10.0
    @AppStorage("numberEveryMM") private var numberEveryMM = 10.0
    @AppStorage("rulerColorMode") private var rulerColorMode = "yellow"

    @State private var showingSettings = false

    private let majorTickEvery = 10
    private let mediumTickEvery = 5

    var body: some View {
        GeometryReader { geo in
            let rulerWidth = max(1, geo.size.width * rulerWidthRatio)
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let pxPerMM = mmSpacing

            ZStack {
                Color.clear
                    .ignoresSafeArea()

                Rectangle()
                    .fill(rulerColor)
                    .frame(width: rulerWidth, height: geo.size.height)
                    .position(x: centerX, y: centerY)

                RulerTicks(
                    rulerWidth: rulerWidth,
                    height: geo.size.height,
                    centerX: centerX,
                    centerY: centerY,
                    pxPerMM: pxPerMM,
                    tickLength: tickLength,
                    tickWidth: tickWidth,
                    majorTickEvery: majorTickEvery,
                    mediumTickEvery: mediumTickEvery,
                    zeroOffsetMM: zeroOffsetMM
                )

                RulerNumbers(
                    height: geo.size.height,
                    centerX: centerX,
                    centerY: centerY,
                    pxPerMM: pxPerMM,
                    everyMM: numberEveryMM,
                    zeroOffsetMM: zeroOffsetMM,
                    fontSize: numberFontSize,
                    fontDesign: fontDesign,
                    fontWeight: fontWeight
                )

                if showZeroSlider {
                    ZeroSliderPanel(zeroOffsetMM: $zeroOffsetMM)
                        .position(x: centerX, y: geo.size.height - 65)
                }

                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(width: 44, height: 44)
                        .background(.white.opacity(0.92))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .position(x: geo.size.width - 32, y: 32)
            }
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    private var rulerColor: Color {
        switch rulerColorMode {
        case "white": return .white
        case "black": return .black
        default: return .yellow
        }
    }
}

private struct RulerTicks: View {
    let rulerWidth: CGFloat
    let height: CGFloat
    let centerX: CGFloat
    let centerY: CGFloat
    let pxPerMM: CGFloat
    let tickLength: CGFloat
    let tickWidth: CGFloat
    let majorTickEvery: Int
    let mediumTickEvery: Int
    let zeroOffsetMM: Double

    var body: some View {
        let visibleMM = Int(ceil(Double(height / pxPerMM) / 2.0)) + 3
        let values = Array(-visibleMM...visibleMM)

        ZStack {
            ForEach(values, id: \.self) { mm in
                let y = centerY + CGFloat(Double(mm) - zeroOffsetMM) * pxPerMM
                let length: CGFloat
                if mm % majorTickEvery == 0 {
                    length = rulerWidth
                } else if mm % mediumTickEvery == 0 {
                    length = min(rulerWidth, tickLength * 0.72)
                } else {
                    length = min(rulerWidth, tickLength)
                }

                Rectangle()
                    .fill(Color.black)
                    .frame(width: length, height: max(0.5, tickWidth))
                    .position(x: centerX, y: y)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct RulerNumbers: View {
    let height: CGFloat
    let centerX: CGFloat
    let centerY: CGFloat
    let pxPerMM: CGFloat
    let everyMM: Double
    let zeroOffsetMM: Double
    let fontSize: CGFloat
    let fontDesign: String
    let fontWeight: String

    var body: some View {
        let visibleMM = Int(ceil(Double(height / pxPerMM) / 2.0)) + 3
        let step = max(1, Int(everyMM.rounded()))
        let values = Array(stride(from: -visibleMM, through: visibleMM, by: step))

        ZStack {
            ForEach(values, id: \.self) { mm in
                let y = centerY + CGFloat(Double(mm) - zeroOffsetMM) * pxPerMM

                Text(mm == 0 ? "0" : "\(mm)")
                    .font(numberFont)
                    .foregroundStyle(Color.black)
                    .frame(width: 90, height: fontSize + 12)
                    .position(x: centerX, y: y)
                    .contentShape(Rectangle())
            }
        }
        .allowsHitTesting(false)
    }

    private var numberFont: Font {
        let design: Font.Design = fontDesign == "monospaced" ? .monospaced : .rounded
        let weight: Font.Weight
        switch fontWeight {
        case "semibold": weight = .semibold
        case "regular": weight = .regular
        default: weight = .bold
        }
        return .system(size: fontSize, weight: weight, design: design)
    }
}

private struct ZeroSliderPanel: View {
    @Binding var zeroOffsetMM: Double

    var body: some View {
        HStack(spacing: 10) {
            Text("0")
                .font(.system(size: 15, weight: .bold, design: .rounded))

            Slider(value: $zeroOffsetMM, in: -100...100, step: 1)
                .tint(.yellow)

            Text("\(Int(zeroOffsetMM)) mm")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .frame(width: 62, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 300)
        .background(.white.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(radius: 5)
    }
}
