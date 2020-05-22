import SwiftUI

struct BoardView: View {
    private static let cellCount = CGFloat(Board.axisLength)
    private static let borderCount = cellCount + 1
    private static let borderWidth = CGFloat(1)
    private static let roomForBorders = (borderCount * borderWidth)
    private static let notesAxisLength = Int(Float(Board.axisLength).squareRoot().rounded(.up))

    @Binding private var board: Board
    @Binding private var selection: Board.Location?

    private var onTapGesture: (Board.Cell) -> Void

    @State private var boardSize = UIScreen.main.bounds.width
    @State private var cellSize = (UIScreen.main.bounds.width - Self.roomForBorders) / Self.cellCount
    @State private var notesSubCellSize = (UIScreen.main.bounds.width - Self.roomForBorders) / (Self.cellCount * CGFloat(Self.notesAxisLength))

    init(
        _ board: Binding<Board>,
        selection: Binding<Board.Location?>,
        onTapGesture: @escaping (Board.Cell) -> Void = { cell in }
    ) {
        self._board = board
        self._selection = selection
        self.onTapGesture = onTapGesture
    }

    var body: some View {
        VStack(spacing: 0) {
            self.divider(.Horizontal)
                .scaleEffect(3)

            ForEach(self.board.rows) { row in
                Group {
                    HStack(spacing: 0) {
                        self.divider(.Vertical)
                            .scaleEffect(3)

                        ForEach(row) { cell in
                            Group {
                                Button(action: { self.onTapGesture(cell) }) {
                                    self.cellView(cell)
                                        .font(.system(size: 500))
                                        .minimumScaleFactor(0.001)
                                        .scaledToFit()
                                        .frame(
                                            width: self.cellSize,
                                            height: self.cellSize
                                        )
                                        .foregroundColor(Color(UIColor.label))
                                }
                                .background(
                                    self.selection == cell.location ? Color.blue : Color.clear
                                )

                                self.divider(.Vertical, coordinate: cell.location.column)
                            }

                        }
                    }
                    .frame(height: self.cellSize)

                    self.divider(.Horizontal, coordinate: row.row)
                }
            }
        }
        .frame(
            width: self.boardSize,
            height: self.boardSize
        )
        .clipped()
        .background(
            GeometryReader { (geometry) -> Color in
                let frame = geometry.frame(in: .local)
                DispatchQueue.main.async {
                    let maybeBoardSize = [frame.width, frame.height]
                        .filter { $0 > 0 }
                        .min()
                    if let boardSize = maybeBoardSize {
                        self.boardSize = boardSize
                        self.cellSize = (boardSize - Self.roomForBorders) / Self.cellCount
                        self.notesSubCellSize = (boardSize - Self.roomForBorders) / (Self.cellCount * CGFloat(Self.notesAxisLength))
                    }
                }
                return Color.clear
            }
        )
    }

    private func cellView(_ cell: Board.Cell) -> AnyView {
        switch cell.value {
        case .Empty:
            return AnyView(Spacer())
        case let .Value(digit):
            return AnyView(Text(String(describing: digit)))
        case let .Note(digits):
            return AnyView(self.notesView(digits))
        }
    }

    private func notesView(_ digits: Set<Board.Cell.Digit>) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<Self.notesAxisLength) { row in
                HStack(spacing: 0) {
                    ForEach(0..<Self.notesAxisLength) { column in
                        Group {
                            self.notesSubView(digits, row, column)
                                .frame(
                                    width: self.notesSubCellSize,
                                    height: self.notesSubCellSize
                                )
                        }
                    }
                }
            }
        }
    }

    private func notesSubView(_ digits: Set<Board.Cell.Digit>, _ row: Board.Location.Coordinate, _ column: Board.Location.Coordinate) -> Text {
        let index = Int(row * Self.notesAxisLength + column + 1)

        if let digit = Board.Cell.Digit(rawValue: index), digits.contains(digit) {
            return Text(String(describing: digit))
        } else {
            return Text(" ")
        }
    }

    private func divider(_ direction: DividerDirection, coordinate maybeCoordinate: Board.Location.Coordinate? = nil) -> AnyView {
        let divider = baseDivider(direction)
            .background(Color(UIColor.systemGray))

        if let coordinate = maybeCoordinate {
            if coordinate % 3 == 2 {
                return AnyView(divider.scaleEffect(3))
            }
        }

        return AnyView(divider)
    }

    private func baseDivider(_ direction: DividerDirection) -> some View {
        switch direction {
        case .Horizontal: return Divider().frame(height: Self.borderWidth)
        case .Vertical: return Divider().frame(width: Self.borderWidth)
        }
    }

    private enum DividerDirection {
        case Vertical, Horizontal
    }
}

#if DEBUG
struct BoardView_Previews: PreviewProvider {
    static private var dimensions: CGFloat = UIScreen.main.bounds.width + 40

    static private var board = Binding<Board>(
        get: {
            let b = Board()
            b[Board.Location(row: 2, column: 5)]?.value = .Value(._9)
            b[Board.Location(row: 4, column: 7)]?.value = .Note([._9])
            return b
        },
        set: { newValue in }
    )

    @State static private var selection: Board.Location? = nil

    static var previews: some View {
        Group {
            BoardView(board, selection: $selection)
                .padding()
                .previewLayout(.fixed(width: Self.dimensions, height: Self.dimensions))
                .previewDisplayName("Light Mode")

            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                BoardView(board, selection: $selection)
                    .padding()
            }
                .previewLayout(.fixed(width: Self.dimensions, height: Self.dimensions))
                .previewDisplayName("Dark Mode")
                .colorScheme(.dark)
        }
    }
}
#endif
