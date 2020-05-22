import Combine

class Board: ObservableObject {
    static let axis = 0..<axisLength
    static let axisLength: Location.Coordinate = 9

    private var cells: [Location: Cell]

    init() {
        let tuples: [(Location, Cell)] = square(Self.axis).map { tuple in
            let location = Location(row: tuple.a, column: tuple.b)
            return (location, Cell(location: location, value: .Empty))
        }

        self.cells = Dictionary(uniqueKeysWithValues: tuples)
    }

    var rows: RowCollection {
        RowCollection(self)
    }

    subscript(_ location: Location) -> Cell? {
        get { cells[location] }
        set { cells[location] = newValue }
    }

    struct Cell {
        let location: Location
        var value: Value

        enum Value: Equatable {
            case Empty, Value(Digit)
        }

        enum Digit: Int, CaseIterable, Equatable {
            case _1 = 1, _2 = 2, _3 = 3, _4 = 4, _5 = 5, _6 = 6, _7 = 7, _8 = 8, _9 = 9
        }
    }

    struct Location: Hashable {
        typealias Coordinate = Int
        let row, column: Coordinate
    }

    struct RowCollection: RandomAccessCollection {
        typealias Index = Location.Coordinate
        typealias Element = Row

        var startIndex: Index { 0 }
        var endIndex: Index { Board.axisLength }

        private let board: Board

        init(_ board: Board) {
            self.board = board
        }

        subscript(position: Index) -> Element {
            Row(position, board)
        }

        func index(after i: Index) -> Index { i + 1 }
        func index(before i: Index) -> Index { i - 1 }
    }

    struct Row: RandomAccessCollection {
        typealias Index = Location.Coordinate
        typealias Element = Cell

        var startIndex: Index { 0 }
        var endIndex: Index { Board.axisLength }

        let row: RowCollection.Index
        private let board: Board

        init(_ row: RowCollection.Index, _ board: Board) {
            self.row = row
            self.board = board
        }

        subscript(column: Index) -> Element {
            board[Location(row: row, column: column)]!
        }

        func index(after i: Index) -> Index { i + 1 }
        func index(before i: Index) -> Index { i - 1 }
    }
}

// MARK: Identifiable

extension Board.Row: Identifiable {
    typealias ID = Board.RowCollection.Index
    var id: ID { return row }
}

extension Board.Cell: Identifiable {
    typealias ID = Board.Location
    var id: ID { return location }
}

extension Board.Cell.Digit: Identifiable {
    typealias ID = Board.Cell.Digit.RawValue
    var id: ID { rawValue }
}

// MARK: String Conversions

extension Board: CustomDebugStringConvertible {
    var debugDescription: String {
        rows.map { row in
            row.map { cell in
                cell.debugDescription
            }.joined()
        }.joined(separator: "\n")
    }
}

extension Board.Cell: CustomDebugStringConvertible {
    var debugDescription: String { value.debugDescription }
}

extension Board.Cell.Value: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .Empty: return " "
        case let .Value(digit): return digit.description
        }
    }
}

extension Board.Cell.Digit: CustomStringConvertible {
    var description: String { String(describing: rawValue) }
}
