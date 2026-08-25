import SwiftUI

struct RulerView: View {

    // Положение нулевой отметки в миллиметрах.
    // 0 = нижний край экрана.
    // Значение сохраняется между запусками.
    @AppStorage("zeroOffsetMM")
    private var zeroOffsetMM: Double = 0

    @State private var showZeroSlider = false

    // iPhone 17:
    // дисплей 402 × 874 pt, диагональ 6.3".
    //
    // Физическая высота активной области дисплея ≈ 145.3 мм.
    // Поэтому:
    // 874 pt / 145.3 мм ≈ 6.02 pt/мм
    //
    // Используем фиксированное значение, чтобы линейка
    // не требовала ручной калибровки.
    private let pointsPerMillimeter: CGFloat = 6.02

    // Жёлтая часть занимает четверть экрана.
    private let rulerWidthRatio: CGFloat = 0.25

    var body: some View {

        GeometryReader { geo in

            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            let rulerWidth = screenWidth * rulerWidthRatio

            // Положение нуля в экранных точках.
            //
            // При 0 мм ноль находится ровно внизу.
            // При увеличении значения ноль поднимается вверх.
            let zeroY =
                screenHeight -
                CGFloat(zeroOffsetMM) * pointsPerMillimeter

            ZStack(alignment: .topLeading) {

                // Белый фон всего экрана
                Color.white
                    .ignoresSafeArea()

                // -------------------------------------------------
                // ЖЁЛТАЯ ЛИНЕЙКА
                // -------------------------------------------------

                Canvas { context, size in

                    // Жёлтый фон линейки
                    context.fill(
                        Path(
                            CGRect(
                                x: 0,
                                y: 0,
                                width: rulerWidth,
                                height: size.height
                            )
                        ),
                        with: .color(Color.yellow)
                    )

                    // Сколько миллиметров помещается на экране
                    let visibleMillimeters =
                        Int(ceil(Double(screenHeight) /
                                 Double(pointsPerMillimeter))) + 2

                    for mm in 0...visibleMillimeters {

                        // Положение конкретной отметки.
                        //
                        // 0 мм находится в zeroY.
                        // 1 мм выше на pointsPerMillimeter.
                        let y =
                            zeroY -
                            CGFloat(mm) * pointsPerMillimeter

                        // Не рисуем то, что полностью за экраном.
                        guard y >= -2 && y <= screenHeight + 2 else {
                            continue
                        }

                        let isTen = mm % 10 == 0
                        let isFive = mm % 5 == 0

                        // Длина штриха.
                        //
                        // Штрихи идут от обоих краёв к центру.
                        let tickLength: CGFloat

                        if isTen {
                            tickLength = rulerWidth * 0.30
                        } else if isFive {
                            tickLength = rulerWidth * 0.22
                        } else {
                            tickLength = rulerWidth * 0.13
                        }

                        let lineWidth: CGFloat =
                            isTen ? 2.0 : 1.2

                        // -------------------------------------------------
                        // ЛЕВЫЙ ШТРИХ
                        // -------------------------------------------------

                        var leftPath = Path()

                        leftPath.move(
                            to: CGPoint(
                                x: 0,
                                y: y
                            )
                        )

                        leftPath.addLine(
                            to: CGPoint(
                                x: tickLength,
                                y: y
                            )
                        )

                        context.stroke(
                            leftPath,
                            with: .color(.black),
                            lineWidth: lineWidth
                        )

                        // -------------------------------------------------
                        // ПРАВЫЙ ШТРИХ
                        // -------------------------------------------------

                        var rightPath = Path()

                        rightPath.move(
                            to: CGPoint(
                                x: rulerWidth,
                                y: y
                            )
                        )

                        rightPath.addLine(
                            to: CGPoint(
                                x: rulerWidth - tickLength,
                                y: y
                            )
                        )

                        context.stroke(
                            rightPath,
                            with: .color(.black),
                            lineWidth: lineWidth
                        )
                    }
                }
                .frame(
                    width: rulerWidth,
                    height: screenHeight
                )

                // -------------------------------------------------
                // ЦИФРЫ
                // -------------------------------------------------

                ForEach(
                    stride(
                        from: 0,
                        through: 200,
                        by: 10
                    ),
                    id: \.self
                ) { mm in

                    let y =
                        zeroY -
                        CGFloat(mm) * pointsPerMillimeter

                    // Небольшой запас, чтобы цифры не появлялись
                    // за пределами экрана.
                    if y > -40 && y < screenHeight + 40 {

                        Text("\(mm)")
                            .font(
                                .system(
                                    size: 25,
                                    weight: .bold,
                                    design: .monospaced
                                )
                            )
                            .foregroundStyle(.black)
                            .frame(
                                width: rulerWidth,
                                height: 32
                            )
                            .position(
                                x: rulerWidth / 2,
                                y: y
                            )
                    }
                }

                // -------------------------------------------------
                // ПЕРЕКЛЮЧАТЕЛЬ ПОЛЗУНКА
                // -------------------------------------------------

                VStack {
                    Spacer()

                    HStack {

                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showZeroSlider.toggle()
                            }
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 20, weight: .semibold))
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

                        if showZeroSlider {

                            // -------------------------------------------------
                            // ПОЛЗУНОК НУЛЯ
                            // -------------------------------------------------

                            VStack(spacing: 4) {

                                Text(
                                    "0: \(zeroOffsetMM, specifier: "%.0f") мм"
                                )
                                .font(
                                    .system(
                                        size: 13,
                                        weight: .semibold,
                                        design: .rounded
                                    )
                                )
                                .foregroundStyle(.black)

                                Slider(
                                    value: Binding(
                                        get: {
                                            zeroOffsetMM
                                        },
                                        set: { newValue in
                                            zeroOffsetMM = newValue
                                        }
                                    ),
                                    in: 0...80,
                                    step: 1
                                )
                                .frame(width: 190)
                                .tint(.black)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
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

                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
                .frame(
                    width: screenWidth,
                    height: screenHeight
                )
            }
            .frame(
                width: screenWidth,
                height: screenHeight
            )
        }

        // Полностью убираем системные края.
        .ignoresSafeArea()

        // Белый интерфейс приложения.
        .preferredColorScheme(.light)
    }
}
