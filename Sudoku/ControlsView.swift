import SwiftUI

struct ControlsView: View {
    private static let buttons = Button.allCases
    private static let buttonCount = CGFloat(Button.allCases.count)
    private static let borderCount = buttonCount + 1
    private static let borderWidth = CGFloat(1)
    private static let roomForBorders = (borderCount * borderWidth)

    @Binding private var state: State

    private var onTapGesture: (Button) -> Void

    @SwiftUI.State private var panelSize = UIScreen.main.bounds.width
    @SwiftUI.State private var cellSize = (UIScreen.main.bounds.width - Self.roomForBorders) / Self.buttonCount

    init(state: Binding<State>, onTapGesture: @escaping (Button) -> Void = { button in }) {
        self._state = state
        self.onTapGesture = onTapGesture
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 0) {
                Divider()

                ForEach(Self.buttons) { button in
                    Group {
                        SwiftUI.Button(action: { self.onTapGesture(button) }) {
                            Text(String(describing: button))
                        }
                        .frame(width: self.cellSize, height: self.cellSize)
                        .background(self.isSelected(button) ? Color.blue : Color.clear)
                        .foregroundColor(self.isSelected(button) ? .white : .blue)

                        Divider()
                    }
                }
            }
            .frame(height: self.cellSize)

            Divider()
        }
        .background(
            GeometryReader { (geometry) -> Color in
                let frame = geometry.frame(in: .local)
                DispatchQueue.main.async {
                    self.panelSize = frame.width
                    self.cellSize = (self.panelSize - Self.roomForBorders) / Self.buttonCount
                }
                return Color.clear
            }
        )
    }

    private func isSelected(_ button: Button) -> Bool {
        self.state == .Button(button)
    }

    enum State: Equatable {
        case None
        case Button(ControlsView.Button)
    }

    enum Button: CaseIterable, CustomStringConvertible, Equatable, Identifiable {
        typealias AllCases = [Self]
        typealias ID = Board.Cell.Digit.ID

        case Digit(Board.Cell.Digit)

        var description: String {
            switch self {
            case let .Digit(digit): return digit.description
            }
        }

        var id: ID {
            switch self {
            case let .Digit(digit): return digit.id
            }
        }

        static var allCases: AllCases {
            allDigitCases
        }

        private static var allDigitCases: AllCases {
            Board.Cell.Digit.allCases.map { .Digit($0) }
        }
    }
}

#if DEBUG
struct ControlsView_Previews: PreviewProvider {
    @State private static var state: ControlsView.State = .None

    static var previews: some View {
        ControlsView(state: self.$state)
    }
}
#endif
