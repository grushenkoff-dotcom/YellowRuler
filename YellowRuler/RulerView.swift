import SwiftUI
import UIKit

struct RulerView: View {

    // MARK: - Настройки

    // Реальный масштаб в POINTS на миллиметр.
    // SwiftUI использует points, а не физические pixels.
    @AppStorage("pointsPerMillimeter")
    private var pointsPerMillimeter: Double = 6.0

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

            ZStack {

                // =====================================================
                // ПРОЗРАЧНЫЙ ФОН
                // =====================================================

                Color.clear
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // =================================================
                    // ВЕРХНЯЯ ПАНЕЛЬ
                    // =================================================

                    HStack {

                        Text("YELLOW RULER")
                            .font(
                                .system(
                                    size: 13,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )
                            .foregroundStyle(.primary)

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

                    // =================================================
                    // ЛИНЕЙКА
                    // =================================================

                    rulerView
                        .frame(
                            width: geo.size.width / 3,
                            height: 110
                        )
                        .background(
                            Color.yellow
                        )
                        .clipped()

                    Spacer()

                    Text("мм • 1 мм")
                        .font(
                            .system(
                                size: 12,
                                weight: .medium,
                                design: .monospaced
                            )
                        )
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 10)
                }
            }
        }

        // =============================================================
        // НАСТРОЙКИ
        // =============================================================

        .sheet(isPresented: $showSettings) {

            SettingsView(
                selectedFont: $rulerFont,
                fontSize: $rulerFontSize,
                fonts: fonts
            )
            .presentationDetents([.medium])
        }

        // =============================================================
        // КАЛИБРОВКА
        // =============================================================

        .sheet(isPresented: $showCalibration) {

            CalibrationView(
                current: pointsPerMillimeter
            ) { value in

                pointsPerMillimeter = value
                showCalibration = false
            }
            .presentationDetents([.medium])
        }

        .preferredColorScheme(.light)
    }

    // MARK: - Линейка

    private var rulerView: some View {

        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {

            HStack(
                spacing: 0
            ) {

                ForEach(0...150, id: \.self) { mm in

                    rulerMillimeter(mm)
                }
            }
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Один миллиметр

    private func rulerMillimeter(
        _ mm: Int
    ) -> some View {

        VStack(
            spacing: 4
        ) {

            Spacer(
                minLength: 0
            )

            // =========================================================
            // ШТРИХ
            // =========================================================

            Rectangle()
                .fill(.black)
                .frame(
                    width: 1,
                    height: tickHeight(mm)
                )

            // =========================================================
            // ЧИСЛО
            // =========================================================

            if mm % 10 == 0 {

                Text("\(mm)")
                    .font(
                        rulerFontValue(
                            size: rulerFontSize
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(
                        width: pointsPerMillimeter * 10,
                        alignment: .center
                    )
                    .multilineTextAlignment(.center)

            } else {

                // Пустое место той же высоты,
                // чтобы все штрихи располагались одинаково.

                Color.clear
                    .frame(
                        height: rulerFontSize + 4
                    )
            }

            Spacer(
                minLength: 0
            )
        }
        .frame(
            width: pointsPerMillimeter,
            height: 110
        )
    }

    // MARK: - Высота штриха

    private func tickHeight(
        _ mm: Int
    ) -> CGFloat {

        if mm % 10 == 0 {
            return 62
        }

        if mm % 5 == 0 {
            return 46
        }

        return 28
    }

    // MARK: - Шрифт линейки

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

                // =====================================================
                // ШРИФТ
                // =====================================================

                Section("Шрифт чисел") {

                    Picker(
                        "Шрифт",
                        selection: $selectedFont
                    ) {

                        ForEach(
                            fonts,
                            id: \.self
                        ) { font in

                            Text(font)
                                .tag(font)
                        }
                    }
                }

                // =====================================================
                // РАЗМЕР
                // =====================================================

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

                    // -------------------------------------------------
                    // Предпросмотр
                    // -------------------------------------------------

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

                // =====================================================
                // ИНФОРМАЦИЯ
                // =====================================================

                Section {

                    Text(
                        "Линейка занимает одну треть ширины экрана. Остальная область остаётся прозрачной."
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

    // MARK: - Preview Font

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
    @State private var points = ""

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {

        NavigationStack {

            Form {

                // =====================================================
                // ИНСТРУКЦИЯ
                // =====================================================

                Section("Калибровка") {

                    Text(
                        "Положи на экран обычную линейку. Укажи длину отрезка в миллиметрах и его длину в points на экране."
                    )

                    Text(
                        "Например: если 100 мм на экране занимают 600 points, введи 100 и 600."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }

                // =====================================================
                // МИЛЛИМЕТРЫ
                // =====================================================

                Section {

                    TextField(
                        "Длина в мм",
                        text: $millimeters
                    )
                    .keyboardType(
                        .decimalPad
                    )

                    TextField(
                        "Длина в points",
                        text: $points
                    )
                    .keyboardType(
                        .decimalPad
                    )
                }

                // =====================================================
                // ТЕКУЩЕЕ ЗНАЧЕНИЕ
                // =====================================================

                Section {

                    Text(
                        "Текущий масштаб: \(current, specifier: "%.3f") pt/мм"
                    )
                }

                // =====================================================
                // СОХРАНИТЬ
                // =====================================================

                Section {

                    Button("Сохранить") {

                        let mmString =
                            millimeters
                                .replacingOccurrences(
                                    of: ",",
                                    with: "."
                                )

                        let pointsString =
                            points
                                .replacingOccurrences(
                                    of: ",",
                                    with: "."
                                )

                        guard

                            let mm = Double(
                                mmString
                            ),

                            let pt = Double(
                                pointsString
                            ),

                            mm > 0,
                            pt > 0

                        else {
                            return
                        }

                        let result =
                            pt / mm

                        onSave(
                            result
                        )
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
