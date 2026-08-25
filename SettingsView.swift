import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

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

    var body: some View {
        NavigationStack {
            Form {
                Section("Линейка") {
                    valueSlider(
                        title: "Ширина",
                        value: $rulerWidthRatio,
                        range: 0.10...1.00,
                        step: 0.01,
                        valueText: "\(Int(rulerWidthRatio * 100)) %"
                    )

                    valueSlider(
                        title: "Масштаб",
                        value: $mmSpacing,
                        range: 4...20,
                        step: 0.5,
                        valueText: String(format: "%.1f pt/мм", mmSpacing)
                    )

                    Picker("Цвет", selection: $rulerColorMode) {
                        Text("Жёлтый").tag("yellow")
                        Text("Белый").tag("white")
                        Text("Чёрный").tag("black")
                    }
                }

                Section("Ноль") {
                    valueSlider(
                        title: "Положение 0",
                        value: $zeroOffsetMM,
                        range: -100...100,
                        step: 1,
                        valueText: "\(Int(zeroOffsetMM)) мм"
                    )

                    Toggle("Показывать ползунок нуля", isOn: $showZeroSlider)

                    Button("Вернуть 0 в центр") {
                        zeroOffsetMM = 0
                    }
                }

                Section("Штрихи") {
                    valueSlider(
                        title: "Длина коротких",
                        value: $tickLength,
                        range: 4...60,
                        step: 1,
                        valueText: "\(Int(tickLength)) pt"
                    )

                    valueSlider(
                        title: "Толщина",
                        value: $tickWidth,
                        range: 0.5...5,
                        step: 0.5,
                        valueText: String(format: "%.1f pt", tickWidth)
                    )
                }

                Section("Цифры") {
                    valueSlider(
                        title: "Размер",
                        value: $numberFontSize,
                        range: 12...60,
                        step: 1,
                        valueText: "\(Int(numberFontSize)) pt"
                    )

                    Picker("Шрифт", selection: $fontDesign) {
                        Text("Округлый").tag("rounded")
                        Text("Моноширинный").tag("monospaced")
                    }

                    Picker("Начертание", selection: $fontWeight) {
                        Text("Обычный").tag("regular")
                        Text("Полужирный").tag("semibold")
                        Text("Жирный").tag("bold")
                    }

                    valueSlider(
                        title: "Шаг цифр",
                        value: $numberEveryMM,
                        range: 5...50,
                        step: 5,
                        valueText: "каждые \(Int(numberEveryMM)) мм"
                    )
                }

                Section {
                    Button("Сбросить все настройки", role: .destructive) {
                        resetDefaults()
                    }
                }
            }
            .navigationTitle("Настройки линейки")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func valueSlider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        step: Double,
        valueText: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                Spacer()
                Text(valueText)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Slider(value: value, in: range, step: step)
        }
        .padding(.vertical, 3)
    }

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

#Preview {
    SettingsView()
}
