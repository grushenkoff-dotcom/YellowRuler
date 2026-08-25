import SwiftUI

struct RulerView: View {
    @AppStorage("rulerWidthRatio") private var rulerWidthRatio: Double = 0.33
    @AppStorage("zeroOffsetMM") private var zeroOffsetMM: Double = 0
    @AppStorage("tickLength") private var tickLength: Double = 18
    @AppStorage("tickWidth") private var tickWidth: Double = 2
    @AppStorage("numberFontSize") private var numberFontSize: Double = 28
    @AppStorage("fontDesign") private var fontDesign: String = "rounded"
    @AppStorage("fontWeight") private var fontWeight: String = "bold"
    @AppStorage("showZeroSlider") private var showZeroSlider: Bool = true
    @AppStorage("mmSpacing") private var mmSpacing: Double = 10
    @AppStorage("numberEveryMM") private var numberEveryMM: Double = 10
    @AppStorage("rulerColorMode") private var rulerColorMode: String = "yellow"

    @State private var showingSettings = false

    var body: some View {
        GeometryReader { geometry in
            rulerContent(size: geometry.size)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    @ViewBuilder
    private func rulerContent(size: CGSize) -> some View {
        let rulerWidth = max(1, size.width * rulerWidthRatio)
        let centerX = size.width / 2
        let centerY = size.height / 2

        ZStack {
            Color.clear
                .ignoresSafeArea()

            Rectangle()
                .fill(rulerColor)
                .frame(width: rulerWidth, height: size.height)
                .position(
                    x: centerX,
                    y: centerY
                )

            RulerTicks(
                rulerWidth: rulerWidth,
                height: size.height,
                centerX: centerX,
                centerY: centerY,
                pxPerMM: mmSpacing,
                tickLength: tickLength,
                tickWidth: tickWidth,
                zeroOffsetMM: zeroOffsetMM
            )

            RulerNumbers(
                height: size.height,
                centerX: centerX,
                centerY: centerY,
                pxPerMM: mmSpacing,
                everyMM: numberEveryMM,
                zeroOffsetMM: zeroOffsetMM,
                fontSize: numberFontSize,
                fontDesign: fontDesign,
                fontWeight: fontWeight
            )

            if showZeroSlider {
                ZeroSliderPanel(
                    zeroOffsetMM: $zeroOffsetMM
                )
                .position(
                    x: centerX,
                    y: size.height - 65
                )
            }

            settingsButton(size: size)
        }
        .ignoresSafeArea()
    }

    private func settingsButton(size: CGSize) -> some View {
        Button {
            showingSettings = true
        } label: {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 19, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.92))
                .clipShape(Circle())
                .shadow(radius: 4)
        }
        .position(
            x: size.width - 32,
            y: 32
        )
    }

    private var rulerColor: Color {
        switch rulerColorMode {
        case "white":
            return .white
        case "black":
            return .black
        default:
            return .yellow
        }
    }
}

// MARK: - Штрихи

private struct RulerTicks: View {
    let rulerWidth: CGFloat
    let height: CGFloat
    let centerX: CGFloat
    let centerY: CGFloat
    let pxPerMM: CGFloat
    let tickLength: CGFloat
    let tickWidth: CGFloat
    let zeroOffsetMM: Double

    private let majorEvery = 10
    private let mediumEvery = 5

    var body: some View {
        let visibleMM = calculateVisibleMM()

        ZStack {
            ForEach(
                -visibleMM...visibleMM,
                id: \.self
            ) { mm in

                tickView(for: mm)
            }
        }
        .allowsHitTesting(false)
    }

    private func calculateVisibleMM() -> Int {
        guard pxPerMM > 0 else {
            return 100
        }

        return Int(
            ceil(
                Double(height / pxPerMM) / 2.0
            )
        ) + 3
    }

    @ViewBuilder
    private func tickView(for mm: Int) -> some View {
        let y =
            centerY +
            CGFloat(
                Double(mm) - zeroOffsetMM
            ) * pxPerMM

        let length = tickLengthFor(mm)

        Rectangle()
            .fill(Color.black)
            .frame(
                width: length,
                height: max(0.5, tickWidth)
            )
            .position(
                x: centerX,
                y: y
            )
    }

    private func tickLengthFor(_ mm: Int) -> CGFloat {
        if mm % majorEvery == 0 {
            return rulerWidth
        }

        if mm % mediumEvery == 0 {
            return min(
                rulerWidth,
                tickLength * 0.72
            )
        }

        return min(
            rulerWidth,
            tickLength
        )
    }
}

// MARK: - Цифры

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
        let visibleMM = calculateVisibleMM()
        let step = calculateStep()

        ZStack {
            ForEach(
                stride(
                    from: -visibleMM,
                    through: visibleMM,
                    by: step
                ),
                id: \.self
            ) { mm in

                numberView(for: mm)
            }
        }
        .allowsHitTesting(false)
    }

    private func calculateVisibleMM() -> Int {
        guard pxPerMM > 0 else {
            return 100
        }

        return Int(
            ceil(
                Double(height / pxPerMM) / 2.0
            )
        ) + 3
    }

    private func calculateStep() -> Int {
        max(
            1,
            Int(everyMM.rounded())
        )
    }

    @ViewBuilder
    private func numberView(for mm: Int) -> some View {
        let y =
            centerY +
            CGFloat(
                Double(mm) - zeroOffsetMM
            ) * pxPerMM

        Text(
            mm == 0
                ? "0"
                : "\(mm)"
        )
        .font(numberFont)
        .foregroundStyle(Color.black)
        .frame(
            width: 100,
            height: fontSize + 12
        )
        .position(
            x: centerX,
            y: y
        )
    }

    private var numberFont: Font {
        let design: Font.Design

        if fontDesign == "monospaced" {
            design = .monospaced
        } else {
            design = .rounded
        }

        let weight: Font.Weight

        switch fontWeight {
        case "regular":
            weight = .regular
        case "semibold":
            weight = .semibold
        default:
            weight = .bold
        }

        return .system(
            size: fontSize,
            weight: weight,
            design: design
        )
    }
}

// MARK: - Ползунок нуля

private struct ZeroSliderPanel: View {
    @Binding var zeroOffsetMM: Double

    var body: some View {
        HStack(spacing: 10) {
            Text("0")
                .font(
                    .system(
                        size: 15,
                        weight: .bold,
                        design: .rounded
                    )
                )

            Slider(
                value: $zeroOffsetMM,
                in: -100...100,
                step: 1
            )
            .tint(.yellow)

            Text(
                "\(Int(zeroOffsetMM)) mm"
            )
            .font(
                .system(
                    size: 14,
                    weight: .semibold,
                    design: .monospaced
                )
            )
            .frame(
                width: 62,
                alignment: .trailing
            )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 300)
        .background(
            Color.white.opacity(0.94)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
        .shadow(radius: 5)
    }
}