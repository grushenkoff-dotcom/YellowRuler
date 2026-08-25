import SwiftUI

struct RulerView: View {

    // MARK: - Настройки

    /// Смещение нулевой отметки вверх от нижнего края экрана.
    /// 0 = ноль точно на нижнем краю.
    @AppStorage("zeroOffsetMM")
    private var zeroOffsetMM: Double = 0

    @State private var showZeroSlider = false

    /// Физический масштаб дисплея iPhone 17.
    /// 874 pt ≈ 145.3 мм
    /// 874 / 145.3 ≈ 6.02 pt/mm
    private let pointsPerMillimeter: CGFloat = 6.02

    /// Линейка занимает четверть ширины экрана.
    private let rulerWidthRatio: CGFloat = 0.25

    // MARK: - Body

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let rulerWidth = width * rulerWidthRatio

            // Нижний край экрана = 0 мм.
            //
            // Если zeroOffsetMM = 0:
            // zeroY находится в самом низу.
            //
            // Если zeroOffsetMM = 10:
            // нулевая отметка поднимается на 10 мм.
            let zeroY =
                height
                - CGFloat(zeroOffsetMM) * pointsPerMillimeter

            ZStack(alignment: .topLeading) {

                // -------------------------------------------------
                // БЕЛЫЙ ФОН
                // -------------------------------------------------

                Color.white
                    .ignoresSafeArea()


                // -------------------------------------------------
                // ЖЁЛТАЯ ЛИНЕЙКА
                // -------------------------------------------------

                Rectangle()
                    .fill(Color.yellow)
                    .frame(
                        width: rulerWidth,
                        height: height
                    )
                    .position(
                        x: rulerWidth / 2,
                        y: height / 2
                    )


                // -------------------------------------------------
                // ШТРИХИ
                // -------------------------------------------------

                RulerTicks(
                    rulerWidth: rulerWidth,
                    screenHeight: height,
                    zeroY: zeroY,
                    pointsPerMillimeter: pointsPerMillimeter
                )
                .frame(
                    width: rulerWidth,
                    height: height,
                    alignment: .topLeading
                )


                // -------------------------------------------------
                // ЦИФРЫ
                // -------------------------------------------------

                RulerNumbers(
                    rulerWidth: rulerWidth,
                    screenHeight: height,
                    zeroY: zeroY,
                    pointsPerMillimeter: pointsPerMillimeter
                )
                .frame(
                    width: rulerWidth,
                    height: height,
                    alignment: .topLeading
                )


                // -------------------------------------------------
                // ПАНЕЛЬ ПОЛЗУНКА
                // -------------------------------------------------

                if showZeroSlider {

                    ZeroSliderPanel(
                        value: $zeroOffsetMM
                    )
                    .position(
                        x: width / 2,
                        y: height - 55
                    )
                }


                // -------------------------------------------------
                // КНОПКА ПОЛЗУНКА
                // -------------------------------------------------

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showZeroSlider.toggle()
                    }
                } label: {

                    Image(systemName: "slider.horizontal.3")
                        .font(
                            .system(
                                size: 20,
                                weight: .semibold
                            )
                        )
                        .foregroundStyle(.black)
                        .frame(
                            width: 46,
                            height: 46
                        )
                        .background(
                            Color.white.opacity(0.92)
                        )
                        .clipShape(Circle())
                        .shadow(
                            color: .black.opacity(0.15),
                            radius: 5
                        )
                }
                .position(
                    x: width - 32,
                    y: height - 32
                )
            }
            .frame(
                width: width,
                height: height
            )
        }
        .ignoresSafeArea()
        .preferredColorScheme(.light)
    }
}


// MARK: - ШТРИХИ ЛИНЕЙКИ

private struct RulerTicks: View {

    let rulerWidth: CGFloat
    let screenHeight: CGFloat
    let zeroY: CGFloat
    let pointsPerMillimeter: CGFloat

    var body: some View {

        ZStack(alignment: .topLeading) {

            ForEach(
                0...160,
                id: \.self
            ) { millimeter in

                let y =
                    zeroY
                    - CGFloat(millimeter) * pointsPerMillimeter

                let isTen = millimeter % 10 == 0
                let isFive = millimeter % 5 == 0

                let tickLength: CGFloat =
                    isTen
                    ? rulerWidth * 0.92
                    : isFive
                        ? rulerWidth * 0.70
                        : rulerWidth * 0.48

                let lineWidth: CGFloat =
                    isTen
                    ? 2.2
                    : isFive
                        ? 1.6
                        : 1.2

                if y >= -3 && y <= screenHeight + 3 {

                    TickPair(
                        rulerWidth: rulerWidth,
                        y: y,
                        tickLength: tickLength,
                        lineWidth: lineWidth
                    )
                }
            }
        }
    }
}


// MARK: - ПАРА ШТРИХОВ

private struct TickPair: View {

    let rulerWidth: CGFloat
    let y: CGFloat
    let tickLength: CGFloat
    let lineWidth: CGFloat

    var body: some View {

        ZStack(alignment: .topLeading) {

            // Левый штрих.
            Rectangle()
                .fill(Color.black)
                .frame(
                    width: tickLength,
                    height: lineWidth
                )
                .position(
                    x: tickLength / 2,
                    y: y
                )

            // Правый штрих.
            Rectangle()
                .fill(Color.black)
                .frame(
                    width: tickLength,
                    height: lineWidth
                )
                .position(
                    x: rulerWidth - tickLength / 2,
                    y: y
                )
        }
    }
}


// MARK: - ЦИФРЫ

private struct RulerNumbers: View {

    let rulerWidth: CGFloat
    let screenHeight: CGFloat
    let zeroY: CGFloat
    let pointsPerMillimeter: CGFloat

    var body: some View {

        ZStack(alignment: .topLeading) {

            ForEach(
                0...16,
                id: \.self
            ) { index in

                let millimeter = index * 10

                let y =
                    zeroY
                    - CGFloat(millimeter) * pointsPerMillimeter

                if y >= -35 && y <= screenHeight + 35 {

                    Text("\(millimeter)")
                        .font(
                            .system(
                                size: 27,
                                weight: .bold,
                                design: .monospaced
                            )
                        )
                        .foregroundStyle(Color.black)
                        .frame(
                            width: rulerWidth,
                            height: 34
                        )
                        .position(
                            x: rulerWidth / 2,
                            y: y
                        )
                }
            }
        }
    }
}


// MARK: - ПОЛЗУНОК

private struct ZeroSliderPanel: View {

    @Binding var value: Double

    var body: some View {

        HStack(spacing: 12) {

            Text(
                "0: \(Int(value)) мм"
            )
            .font(
                .system(
                    size: 15,
                    weight: .semibold,
                    design: .rounded
                )
            )
            .foregroundStyle(Color.black)

            Slider(
                value: $value,
                in: 0...80,
                step: 1
            )
            .frame(
                width: 190
            )
            .tint(Color.black)
        }
        .padding(
            .horizontal,
            16
        )
        .padding(
            .vertical,
            10
        )
        .background(
            Color.white.opacity(0.95)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
        .shadow(
            color: .black.opacity(0.18),
            radius: 8
        )
    }
}
