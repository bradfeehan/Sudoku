import SwiftUI

struct BoardView: View {
    private static let cellCount = CGFloat(Board.axisLength)
    private static let borderCount = cellCount + 1
    private static let borderWidth = CGFloat(1)
    private static let roomForBorders = (borderCount * borderWidth)

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
                                    self.cellView(cell).foregroundColor(Color(UIColor.label))
                                }
                                .frame(
                                    width: self.cellSize,
                                    height: self.cellSize
                                )
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
                    }
                }
                return Color.clear
            }
        )
    }

    private func cellView(_ cell: Board.Cell) -> some View {
        switch cell.value {
        case .Empty: return Text(" ")
        case let .Value(digit): return Text(String(describing: digit))
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

    @State static private var board = Board()
    @State static private var selection: Board.Location? = nil

    static var previews: some View {
        Group {
            BoardView($board, selection: $selection)
                .padding()
                .previewLayout(.fixed(width: Self.dimensions, height: Self.dimensions))
                .previewDisplayName("Light Mode")

            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                BoardView($board, selection: $selection)
                    .padding()
            }
                .previewLayout(.fixed(width: Self.dimensions, height: Self.dimensions))
                .previewDisplayName("Dark Mode")
                .colorScheme(.dark)
        }
    }
}
#endif
