import SwiftUI
import UIKit

struct RulerView: View {

    // MARK: - Saved settings

    @AppStorage("pixelsPerMillimeter")
    private var pixelsPerMillimeter: Double = 0

    @AppStorage("rulerFontSize")
    private var rulerFontSize: Double = 24

    @AppStorage("rulerFontDesign")
    private var rulerFontDesign: String = "default"

    @State private var showCalibration = false

    // MARK: - Body

    var body: some View {

        GeometryReader { geo in

            let rulerWidth = geo.size.width / 3.0

            ZStack(alignment: .leading) {

                // Остальная часть экрана полностью прозрачна.
                Color.clear
                    .ignoresSafeArea()

                // MARK: Ruler

                RulerScaleView(
                    width: rulerWidth,
                    height: geo.size.height,
                    pixelsPerMillimeter: calibratedScale,
                    fontSize: rulerFontSize,
                    fontDesign: selectedFontDesign
                )
                .frame(
                    width: rulerWidth,
                    height: geo.size.height
                )
                .clipped()

                // MARK: Menu button

                VStack {
                    HStack {
                        Spacer()

                        Menu {

                            Section("Размер цифр") {

                                Button("16 pt") {
                                    rulerFontSize = 16
                                }

                                Button("20 pt") {
                                    rulerFontSize = 20
                                }

                                Button("24 pt") {
                                    rulerFontSize = 24
                                }

                                Button("28 pt") {
                                    rulerFontSize = 28
                                }

                                Button("32 pt") {
                                    rulerFontSize = 32
                                }

                                Button("36 pt") {
                                    rulerFontSize = 36
                                }

                                Button("42 pt") {
                                    rulerFontSize = 42
                                }
                            }

                            Section("Шрифт") {

                                Button {
                                    rulerFontDesign = "default"
                                } label: {
                                    Label(
                                        "Обычный",
                                        systemImage:
                                            rulerFontDesign == "default"
                                            ? "checkmark"
                                            : ""
                                    )
                                }

                                Button {
                                    rulerFontDesign = "rounded"
                                } label: {
                                    Label(
                                        "Закруглённый",
                                        systemImage:
                                            rulerFontDesign == "rounded"
                                            ? "checkmark"
                                            : ""
                                    )
                                }

                                Button {
                                    rulerFontDesign = "serif"
                                } label: {
                                    Label(
                                        "С засечками",
                                        systemImage:
                                            rulerFontDesign == "serif"
                                            ? "checkmark"
                                            : ""
                                    )
                                }

                                Button {
                                    rulerFontDesign = "monospaced"
                                } label: {
                                    Label(
                                        "Моноширинный",
                                        systemImage:
                                            rulerFontDesign == "monospaced"
                                            ? "checkmark"
                                            : ""
                                    )
                                }
                            }

                            Divider()

                            Button {
                                showCalibration = true
                            } label: {
                                Label(
                                    "Калибровка",
                                    systemImage: "ruler"
                                )
                            }

                        } label: {

                            Image(systemName: "ellipsis")
                                .font(
                                    .system(
                                        size: 20,
                                        weight: .bold
                                    )
                                )
                                .foregroundStyle(.primary)
                                .frame(
                                    width: 52,
                                    height: 52
                                )
                                .background(
                                    .ultraThinMaterial
                                )
                                .clipShape(Circle())
                        }

                        .padding(.trailing, 18)
                        .padding(.top, 14)
                    }

                    Spacer()
                }
            }
        }

        .sheet(isPresented: $showCalibration) {

            CalibrationView(
                current: pixelsPerMillimeter
            ) { value in

                pixelsPerMillimeter = value
                showCalibration = false
            }

            .presentationDetents([.medium])
        }
    }

    // MARK: - Calibration

    private var calibratedScale: Double {

        if pixelsPerMillimeter > 0 {
            return pixelsPerMillimeter
        }

        // Временный масштаб до первой калибровки.
        return 3.78
    }

    // MARK: - Font

    private var selectedFontDesign: Font.Design {

        switch rulerFontDesign {

        case "rounded":
            return .rounded

        case "serif":
            return .serif

        case "monospaced":
            return .monospaced

        default:
            return .default
        }
    }
}


// MARK: - Ruler Scale

struct RulerScaleView: View {

    let width: CGFloat
    let height: CGFloat
    let pixelsPerMillimeter: Double
    let fontSize: Double
    let fontDesign: Font.Design

    var body: some View {

        Canvas { context, size in

            let scale =
                CGFloat(pixelsPerMillimeter)

            let totalMillimeters =
                Int(ceil(Double(height) / pixelsPerMillimeter))

            // Линейка занимает всю свою ширину.
            // Фон самой линейки слегка прозрачный,
            // всё остальное остаётся прозрачным.

            context.fill(
                Path(
                    CGRect(
                        x: 0,
                        y: 0,
                        width: width,
                        height: height
                    )
                ),
                with: .color(
                    Color.yellow.opacity(0.42)
                )
            )

            for mm in 0...totalMillimeters {

                let y =
                    CGFloat(mm) * scale

                if y > height {
                    break
                }

                let isCentimeter =
                    mm % 10 == 0

                let isFiveMillimeter =
                    mm % 5 == 0

                // Длина штриха.
                let tickWidth: CGFloat

                if isCentimeter {

                    tickWidth = width * 0.72

                } else if isFiveMillimeter {

                    tickWidth = width * 0.52

                } else {

                    tickWidth = width * 0.32
                }

                let lineWidth: CGFloat =
                    isCentimeter ? 2.0 : 1.0

                var tick = Path()

                tick.move(
                    to: CGPoint(
                        x: width - tickWidth,
                        y: y
                    )
                )

                tick.addLine(
                    to: CGPoint(
                        x: width,
                        y: y
                    )
                )

                context.stroke(
                    tick,
                    with: .color(.black),
                    lineWidth: lineWidth
                )

                // MARK: Numbers

                if isCentimeter {

                    let centimeter =
                        mm / 10

                    let text =
                        Text("\(centimeter)")
                            .font(
                                .system(
                                    size: fontSize,
                                    weight: .medium,
                                    design: fontDesign
                                )
                            )
                            .foregroundStyle(.black)

                    let resolved =
                        context.resolve(text)

                    // Число строго по центру всей
                    // ширины линейки.
                    let centerX =
                        width / 2.0

                    context.draw(
                        resolved,
                        at: CGPoint(
                            x: centerX,
                            y: y
                        ),
                        anchor: .center
                    )
                }
            }
        }
    }
}


// MARK: - Calibration

struct CalibrationView: View {

    let current: Double

    let onSave: (Double) -> Void

    @State private var millimeters = "100"
    @State private var pixels = ""

    var body: some View {

        NavigationStack {

            Form {

                Section("Калибровка") {

                    Text(
                        """
                        Положи на экран обычную линейку \
                        или банковскую карту и измерь \
                        известную длину.
                        """
                    )

                    TextField(
                        "Длина в мм",
                        text: $millimeters
                    )
                    .keyboardType(.decimalPad)

                    TextField(
                        "Длина в пикселях",
                        text: $pixels
                    )
                    .keyboardType(.decimalPad)
                }

                if current > 0 {

                    Section {

                        Text(
                            "Текущее значение: " +
                            "\(current, specifier: "%.3f") px/мм"
                        )
                    }
                }

                Section {

                    Button("Сохранить") {

                        let mmString =
                            millimeters
                                .replacingOccurrences(
                                    of: ",",
                                    with: "."
                                )

                        let pxString =
                            pixels
                                .replacingOccurrences(
                                    of: ",",
                                    with: "."
                                )

                        guard
                            let mm = Double(mmString),
                            let px = Double(pxString),
                            mm > 0,
                            px > 0
                        else {
                            return
                        }

                        onSave(px / mm)
                    }
                }
            }

            .navigationTitle("Калибровка")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}