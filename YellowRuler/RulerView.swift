import SwiftUI
import UIKit

struct RulerView: View {

    // MARK: - Настройки

    @AppStorage("pixelsPerMillimeter")
    private var pixelsPerMillimeter: Double = 0

    @AppStorage("rulerFont")
    private var rulerFont: String = "Monospaced"

    @AppStorage("rulerFontSize")
    private var rulerFontSize: Double = 14

    @State private var showCalibration = false
    @State private var showSettings = false

    // MARK: - Доступные шрифты

    private let fonts = [
        "System",
        "Monospaced",
        "Serif",
        "Rounded"
    ]

    // MARK: - Body

    var body: some View {

        GeometryReader { geo in

            let scale =
                pixelsPerMillimeter > 0
                ? pixelsPerMillimeter
                : UIScreen.main.scale * 3.0

            ZStack {

                // ВЕСЬ ФОН ПРОЗРАЧНЫЙ
                Color.clear
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // MARK: Верхнее меню

                    HStack {

                        Text("YELLOW RULER")
                            .font(
                                .system(
                                    size: 13,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )

                        Spacer()

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18))
                        }

                        Button("Калибровка") {
                            showCalibration = true
                        }
                        .font(
                            .system(
                                size: 13,
                                weight: .semibold
                            )
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    Spacer()

                    // MARK: Линейка

                    ScrollView(
                        .horizontal,
                        showsIndicators: false
                    ) {

                        HStack(spacing: 0) {

                            ForEach(0...150, id: \.self) { mm in

                                VStack(spacing: 5) {

                                    // Штрих

                                    Rectangle()
                                        .fill(.black)
                                        .frame(
                                            width: 1,
                                            height:
                                                mm % 10 == 0
                                                ? 72
                                                : (mm % 5 == 0 ? 52 : 30)
                                        )

                                    // Число

                                    if mm % 10 == 0 {

                                        Text("\(mm)")
                                            .font(
                                                rulerFontValue(
                                                    size: rulerFontSize
                                                )
                                            )
                                            .frame(
                                                width: max(1, scale),
                                                alignment: .center
                                            )
                                            .multilineTextAlignment(.center)
                                    }
                                }

                                // Каждый миллиметр имеет
                                // строго одинаковую ширину
                                .frame(
                                    width: max(1, scale),
                                    alignment: .center
                                )
                            }
                        }
                    }
                    // ВАЖНО:
                    // ширина области линейки = 1/3 экрана
                    .frame(
                        width: geo.size.width / 3,
                        height: 105
                    )
                    .background(
                        Color.yellow
                    )
                    .clipShape(
                        Rectangle()
                    )

                    Spacer()

                    Text("мм • 1 мм")
                        .font(
                            .system(
                                size: 12,
                                weight: .medium,
                                design: .monospaced
                            )
                        )
                        .padding(.bottom, 10)
                }
            }
        }

        // MARK: Настройки

        .sheet(isPresented: $showSettings) {

            SettingsView(
                selectedFont: $rulerFont,
                fontSize: $rulerFontSize,
                fonts: fonts
            )
            .presentationDetents([.medium])
        }

        // MARK: Калибровка

        .sheet(isPresented: $showCalibration) {

            CalibrationView(
                current: pixelsPerMillimeter
            ) { value in

                pixelsPerMillimeter = value
                showCalibration = false
            }
            .presentationDetents([.medium])
        }

        .preferredColorScheme(.light)
    }

    // MARK: - Шрифт

    private func rulerFontValue(
        size: Double
    ) -> Font {

        switch rulerFont {

        case "Monospaced":
            return .system(
                size: size,
                weight: .medium,
                design: .monospaced
            )

        case "Serif":
            return .system(
                size: size,
                weight: .medium,
                design: .serif
            )

        case "Rounded":
            return .system(
                size: size,
                weight: .medium,
                design: .rounded
            )

        default:
            return .system(
                size: size,
                weight: .medium,
                design: .default
            )
        }
    }
}


// MARK: - Настройки

struct SettingsView: View {

    @Binding var selectedFont: String
    @Binding var fontSize: Double

    let fonts: [String]

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {

        NavigationStack {

            Form {

                // MARK: Шрифт

                Section("Шрифт чисел") {

                    Picker(
                        "Шрифт",
                        selection: $selectedFont
                    ) {

                        ForEach(fonts, id: \.self) { font in

                            Text(font)
                                .tag(font)
                        }
                    }
                }

                // MARK: Размер

                Section("Размер чисел") {

                    HStack {

                        Text("Размер")

                        Spacer()

                        Text(
                            "\(Int(fontSize)) pt"
                        )
                        .monospacedDigit()
                    }

                    Slider(
                        value: $fontSize,
                        in: 8...32,
                        step: 1
                    )

                    // Предпросмотр

                    HStack {

                        Spacer()

                        Text("10")
                            .font(
                                previewFont(
                                    size: fontSize
                                )
                            )

                        Text("20")
                            .font(
                                previewFont(
                                    size: fontSize
                                )
                            )

                        Text("30")
                            .font(
                                previewFont(
                                    size: fontSize
                                )
                            )

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                // MARK: Информация

                Section {

                    Text(
                        "Линейка занимает одну треть ширины экрана. Остальная область прозрачная."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }

            .navigationTitle("Настройки")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func previewFont(
        size: Double
    ) -> Font {

        switch selectedFont {

        case "Monospaced":
            return .system(
                size: size,
                weight: .medium,
                design: .monospaced
            )

        case "Serif":
            return .system(
                size: size,
                weight: .medium,
                design: .serif
            )

        case "Rounded":
            return .system(
                size: size,
                weight: .medium,
                design: .rounded
            )

        default:
            return .system(
                size: size,
                weight: .medium,
                design: .default
            )
        }
    }
}


// MARK: - Калибровка

struct CalibrationView: View {

    let current: Double

    let onSave: (Double) -> Void

    @State private var millimeters = "100"
    @State private var pixels = ""

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {

        NavigationStack {

            Form {

                Section("Калибровка") {

                    Text(
                        "Положи на экран обычную линейку или банковскую карту и измерь, сколько пикселей соответствует известной длине."
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
                            "Текущее значение: \(current, specifier: "%.3f") px/мм"
                        )
                    }
                }

                Section {

                    Button("Сохранить") {

                        guard

                            let mm = Double(
                                millimeters.replacingOccurrences(
                                    of: ",",
                                    with: "."
                                )
                            ),

                            let px = Double(
                                pixels.replacingOccurrences(
                                    of: ",",
                                    with: "."
                                )
                            ),

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

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
