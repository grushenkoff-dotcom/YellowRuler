import SwiftUI
import UIKit

struct RulerView: View {
    @AppStorage("pixelsPerMillimeter") private var pixelsPerMillimeter: Double = 0
    @State private var showCalibration = false

    var body: some View {
        GeometryReader { geo in
            let scale = pixelsPerMillimeter > 0 ? pixelsPerMillimeter : UIScreen.main.scale * 3.0

            ZStack {
                Color.yellow.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text("YELLOW RULER")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                        Spacer()
                        Button("Калибровка") {
                            showCalibration = true
                        }
                        .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.yellow.opacity(0.92))

                    Spacer(minLength: 0)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(0...150, id: \.self) { mm in
                                VStack(spacing: 5) {
                                    Rectangle()
                                        .fill(.black)
                                        .frame(
                                            width: 1,
                                            height: mm % 10 == 0 ? 72 : (mm % 5 == 0 ? 52 : 30)
                                        )
                                    if mm % 10 == 0 {
                                        Text("\(mm)")
                                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                                    }
                                }
                                .frame(width: max(1, scale), alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(height: 105)

                    Spacer(minLength: 0)

                    Text("мм • 1 мм")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .padding(.bottom, 10)
                }
            }
            .sheet(isPresented: $showCalibration) {
                CalibrationView(current: pixelsPerMillimeter) { value in
                    pixelsPerMillimeter = value
                    showCalibration = false
                }
                .presentationDetents([.medium])
            }
        }
        .preferredColorScheme(.light)
    }
}

struct CalibrationView: View {
    let current: Double
    let onSave: (Double) -> Void
    @State private var millimeters = "100"
    @State private var pixels = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Калибровка") {
                    Text("Положи на экран обычную линейку или банковскую карту и измерь, сколько пикселей соответствует известной длине.")
                    TextField("Длина в мм", text: $millimeters)
                        .keyboardType(.decimalPad)
                    TextField("Длина в пикселях", text: $pixels)
                        .keyboardType(.decimalPad)
                }

                if current > 0 {
                    Section {
                        Text("Текущее значение: \(current, specifier: "%.3f") px/мм")
                    }
                }

                Button("Сохранить") {
                    guard
                        let mm = Double(millimeters.replacingOccurrences(of: ",", with: ".")),
                        let px = Double(pixels.replacingOccurrences(of: ",", with: ".")),
                        mm > 0, px > 0
                    else { return }
                    onSave(px / mm)
                }
            }
            .navigationTitle("Калибровка")
        }
    }
}
