import SwiftUI

struct RulerView: View {

    // MARK: - Настройки

    @AppStorage("rulerWidthRatio")
    private var rulerWidthRatio: Double = 0.33

    @AppStorage("zeroOffsetMM")
    private var zeroOffsetMM: Double = 0

    @AppStorage("tickLength")
    private var tickLength: Double = 18

    @AppStorage("tickWidth")
    private var tickWidth: Double = 2

    @AppStorage("numberFontSize")
    private var numberFontSize: Double = 28

    @AppStorage("fontDesign")
    private var fontDesign: String = "rounded"

    @AppStorage("fontWeight")
    private var fontWeight: String = "bold"

    @AppStorage("showZeroSlider")
    private var showZeroSlider: Bool = true

    @AppStorage("mmSpacing")
    private var mmSpacing: Double = 10

    @AppStorage("numberEveryMM")
    private var numberEveryMM: Double = 10

    @AppStorage("rulerColorMode")
    private var rulerColorMode: String = "yellow"

    @State private var showingSettings = false

    // MARK: - Основной экран

    var body: some View {

        GeometryReader { geometry in

            let rulerWidth =
                geometry.size.width * rulerWidthRatio

            let rulerCenterX =
                rulerWidth / 2

            let centerY =
                geometry.size.height / 2

            ZStack {

                // ВАЖНО:
                // Никакого фонового Color.black здесь нет.
                Color.clear

                // MARK: Линейка

                Rectangle()
                    .fill(rulerColor)
                    .frame(
                        width: rulerWidth,
                        height: geometry.size.height
                    )
                    .position(
                        x: rulerCenterX,
                        y: centerY
                    )

                // MARK: Штрихи

                RulerTickLayer(
                    rulerWidth: rulerWidth,
                    height: geometry.size.height,
                    centerX: rulerCenterX,
                    centerY: centerY,
                    mmSpacing: mmSpacing,
                    tickLength: tickLength,
                    tickWidth: tickWidth,
                    zeroOffsetMM: zeroOffsetMM
                )

                // MARK: Цифры

                RulerNumberLayer(
                    height: geometry.size.height,
                    centerX: rulerCenterX,
                    centerY: centerY,
                    mmSpacing: mmSpacing,
                    numberEveryMM: numberEveryMM,
                    zeroOffsetMM: zeroOffsetMM,
                    fontSize: numberFontSize,
                    fontDesign: fontDesign,
                    fontWeight: fontWeight,
                    rulerColor: rulerColor
                )

                // MARK: Ползунок нуля

                if showZeroSlider {

                    VStack {

                        Spacer()

                        ZeroSliderView(
                            zeroOffsetMM: $zeroOffsetMM
                        )
                        .padding(.bottom, 55)
                    }
                }
            }

            // MARK: Кнопка настроек
            //
            // Вынесена поверх ВСЕХ слоёв.

            .overlay(alignment: .topTrailing) {

                Button {

                    showingSettings = true

                } label: {

                    Image(
                        systemName: "gearshape.fill"
                    )
                    .font(
                        .system(
                            size: 22,
                            weight: .bold
                        )
                    )
                    .foregroundStyle(.black)
                    .frame(
                        width: 58,
                        height: 58
                    )
                    .background(
                        Circle()
                            .fill(
                                Color.white.opacity(0.95)
                            )
                    )
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: 6,
                        x: 0,
                        y: 2
                    )
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .padding(.top, 35)
                .padding(.trailing, 20)
                .zIndex(100)
            }
            .ignoresSafeArea()
        }

        .ignoresSafeArea()

        // Экран настроек

        .sheet(
            isPresented: $showingSettings
        ) {

            RulerSettingsView()
        }
    }

    // MARK: - Цвет линейки

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


// MARK: - ШТРИХИ

private struct RulerTickLayer: View {

    let rulerWidth: CGFloat
    let height: CGFloat
    let centerX: CGFloat
    let centerY: CGFloat

    let mmSpacing: Double
    let tickLength: Double
    let tickWidth: Double
    let zeroOffsetMM: Double

    var body: some View {

        let visibleMM = visibleMillimeters()

        let values =
            Array(-visibleMM...visibleMM)

        ZStack {

            ForEach(
                values,
                id: \.self
            ) { mm in

                tick(
                    millimeter: mm
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func visibleMillimeters() -> Int {

        guard mmSpacing > 0 else {
            return 100
        }

        let halfHeight =
            Double(height)
            / mmSpacing
            / 2.0

        return Int(
            ceil(halfHeight)
        ) + 3
    }

    private func tick(
        millimeter mm: Int
    ) -> some View {

        let y =
            centerY
            + CGFloat(
                (Double(mm) - zeroOffsetMM)
                * mmSpacing
            )

        let length =
            tickLengthFor(
                millimeter: mm
            )

        return Rectangle()
            .fill(Color.black)
            .frame(
                width: length,
                height: max(
                    0.5,
                    tickWidth
                )
            )
            .position(
                x: centerX,
                y: y
            )
    }

    private func tickLengthFor(
        millimeter mm: Int
    ) -> CGFloat {

        // 10 мм — вся ширина линейки

        if mm % 10 == 0 {

            return rulerWidth
        }

        // 5 мм — длинный штрих

        if mm % 5 == 0 {

            return min(
                rulerWidth,
                max(
                    tickLength,
                    rulerWidth * 0.65
                )
            )
        }

        // 1 мм — короткий штрих

        return min(
            rulerWidth,
            tickLength
        )
    }
}


// MARK: - ЦИФРЫ

private struct RulerNumberLayer: View {

    let height: CGFloat
    let centerX: CGFloat
    let centerY: CGFloat

    let mmSpacing: Double
    let numberEveryMM: Double
    let zeroOffsetMM: Double

    let fontSize: Double
    let fontDesign: String
    let fontWeight: String

    let rulerColor: Color

    var body: some View {

        let visibleMM =
            visibleMillimeters()

        let step =
            max(
                1,
                Int(
                    numberEveryMM.rounded()
                )
            )

        let values =
            Array(-visibleMM...visibleMM)
                .filter {
                    $0 % step == 0
                }

        ZStack {

            ForEach(
                values,
                id: \.self
            ) { mm in

                number(
                    millimeter: mm
                )
            }
        }
        .allowsHitTesting(false)
    }

    private func visibleMillimeters() -> Int {

        guard mmSpacing > 0 else {
            return 100
        }

        let halfHeight =
            Double(height)
            / mmSpacing
            / 2.0

        return Int(
            ceil(halfHeight)
        ) + 3
    }

    private func number(
        millimeter mm: Int
    ) -> some View {

        let y =
            centerY
            + CGFloat(
                (Double(mm) - zeroOffsetMM)
                * mmSpacing
            )

        return Text(
            "\(mm)"
        )
        .font(numberFont)
        .foregroundStyle(Color.black)

        // Небольшая жёлтая подложка
        // закрывает линию под цифрой.

        .padding(
            .horizontal,
            3
        )
        .background(
            rulerColor
        )
        .frame(
            width: 110,
            height: fontSize + 12
        )
        .position(
            x: centerX,
            y: y
        )
    }

    private var numberFont: Font {

        let design: Font.Design

        switch fontDesign {

        case "monospaced":
            design = .monospaced

        default:
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


// MARK: - ПОЛЗУНОК НУЛЯ

private struct ZeroSliderView: View {

    @Binding var zeroOffsetMM: Double

    var body: some View {

        HStack(spacing: 10) {

            Text("0")
                .font(
                    .system(
                        size: 15,
                        weight: .bold
                    )
                )

            Slider(
                value: $zeroOffsetMM,
                in: -100...100,
                step: 1
            )
            .tint(.yellow)

            Text(
                "\(Int(zeroOffsetMM)) мм"
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
        .padding(.vertical, 9)
        .frame(width: 300)
        .background(
            Color.white.opacity(0.95)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
        .shadow(radius: 5)
    }
}


// MARK: - ЭКРАН НАСТРОЕК
// Встроен в этот файл.
// Отдельный SettingsView.swift НЕ НУЖЕН.

private struct RulerSettingsView: View {

    @Environment(\.dismiss)
    private var dismiss

    @AppStorage("rulerWidthRatio")
    private var rulerWidthRatio: Double = 0.33

    @AppStorage("zeroOffsetMM")
    private var zeroOffsetMM: Double = 0

    @AppStorage("tickLength")
    private var tickLength: Double = 18

    @AppStorage("tickWidth")
    private var tickWidth: Double = 2

    @AppStorage("numberFontSize")
    private var numberFontSize: Double = 28

    @AppStorage("fontDesign")
    private var fontDesign: String = "rounded"

    @AppStorage("fontWeight")
    private var fontWeight: String = "bold"

    @AppStorage("showZeroSlider")
    private var showZeroSlider: Bool = true

    @AppStorage("mmSpacing")
    private var mmSpacing: Double = 10

    @AppStorage("numberEveryMM")
    private var numberEveryMM: Double = 10

    @AppStorage("rulerColorMode")
    private var rulerColorMode: String = "yellow"

    var body: some View {

        NavigationStack {

            Form {

                // MARK: Линейка

                Section("Линейка") {

                    settingSlider(
                        title: "Ширина",
                        value: $rulerWidthRatio,
                        range: 0.10...1.00,
                        step: 0.01,
                        text:
                            "\(Int(rulerWidthRatio * 100)) %"
                    )

                    settingSlider(
                        title: "Масштаб",
                        value: $mmSpacing,
                        range: 4...20,
                        step: 0.5,
                        text:
                            String(
                                format: "%.1f pt/мм",
                                mmSpacing
                            )
                    )

                    Picker(
                        "Цвет",
                        selection: $rulerColorMode
                    ) {

                        Text("Жёлтый")
                            .tag("yellow")

                        Text("Белый")
                            .tag("white")

                        Text("Чёрный")
                            .tag("black")
                    }
                }

                // MARK: Ноль

                Section("Ноль") {

                    settingSlider(
                        title: "Положение 0",
                        value: $zeroOffsetMM,
                        range: -100...100,
                        step: 1,
                        text:
                            "\(Int(zeroOffsetMM)) мм"
                    )

                    Toggle(
                        "Показывать ползунок нуля",
                        isOn: $showZeroSlider
                    )

                    Button(
                        "Вернуть 0 в центр"
                    ) {
                        zeroOffsetMM = 0
                    }
                }

                // MARK: Штрихи

                Section("Штрихи") {

                    settingSlider(
                        title: "Длина коротких",
                        value: $tickLength,
                        range: 4...60,
                        step: 1,
                        text:
                            "\(Int(tickLength)) pt"
                    )

                    settingSlider(
                        title: "Толщина",
                        value: $tickWidth,
                        range: 0.5...5,
                        step: 0.5,
                        text:
                            String(
                                format: "%.1f pt",
                                tickWidth
                            )
                    )
                }

                // MARK: Цифры

                Section("Цифры") {

                    settingSlider(
                        title: "Размер",
                        value: $numberFontSize,
                        range: 12...60,
                        step: 1,
                        text:
                            "\(Int(numberFontSize)) pt"
                    )

                    Picker(
                        "Шрифт",
                        selection: $fontDesign
                    ) {

                        Text("Округлый")
                            .tag("rounded")

                        Text("Моноширинный")
                            .tag("monospaced")
                    }

                    Picker(
                        "Начертание",
                        selection: $fontWeight
                    ) {

                        Text("Обычный")
                            .tag("regular")

                        Text("Полужирный")
                            .tag("semibold")

                        Text("Жирный")
                            .tag("bold")
                    }

                    settingSlider(
                        title: "Шаг цифр",
                        value: $numberEveryMM,
                        range: 5...50,
                        step: 5,
                        text:
                            "каждые \(Int(numberEveryMM)) мм"
                    )
                }

                // MARK: Сброс

                Section {

                    Button(
                        "Сбросить все настройки",
                        role: .destructive
                    ) {
                        resetDefaults()
                    }

                } footer: {

                    Text(
                        "После изменения настройки применяются сразу."
                    )
                }
            }
            .navigationTitle(
                "Настройки линейки"
            )
            .navigationBarTitleDisplayMode(
                .inline
            )
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

    // MARK: Ползунок настройки

    private func settingSlider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        text: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 5
        ) {

            HStack {

                Text(title)

                Spacer()

                Text(text)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(
                value: value,
                in: range,
                step: step
            )
        }
        .padding(.vertical, 3)
    }

    // MARK: Сброс

    private func resetDefaults() {

        rulerWidthRatio = 0.33
        zeroOffsetMM = 0
        tickLength = 18
        tickWidth = 2
        numberFontSize = 28
        fontDesign = "rounded"
        fontWeight = "bold"
        showZeroSlider = true
        mmSpacing = 10
        numberEveryMM = 10
        rulerColorMode = "yellow"
    }
}