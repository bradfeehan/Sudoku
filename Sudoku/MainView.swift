import SwiftUI

struct MainView: View {
    @ObservedObject private var boardContainer = BoardContainer()
    @State private var selection: Board.Location? = nil
    @State private var state: ControlsView.State = .None

    private class BoardContainer: ObservableObject {
        @Published var board: Board = Board()
    }

    var body: some View {
        VStack {
            Spacer()

            BoardView(
                self.$boardContainer.board,
                selection: self.$selection,
                onTapGesture: self.handleBoardTap
            )

            Spacer().frame(height: 30)

            ControlsView(state: self.$state, onTapGesture: self.handleControlsTap)

            Spacer()
        }
    }

    private func handleBoardTap(_ cell: Board.Cell) {
        switch self.state {
        case let ControlsView.State.Digit(digit):
            self.modify(cell: cell.location, to: .Value(digit))
        case let .Notes(digit) where digit != nil:
            self.modify(cell: cell.location, to: .Note([digit!]))
        default:
            if self.selection == cell.location {
                self.selection = nil
            } else {
                self.selection = cell.location
            }
        }
    }

    private func handleControlsTap(_ button: ControlsView.Button) {
        switch (button, self.state, self.selection) {

        // Modify selected cell
        case let (.Digit(digit), .None, .some(selection)):
            self.modify(cell: selection, to: .Value(digit))

        case let (.Digit(digit), .Notes(nil), .some(selection)):
            self.modify(cell: selection, to: .Note([digit]))

        // De-select selected button
        case let (.Digit(pressed), .Digit(selected), _) where pressed == selected:
            self.state = .None

        case (.Notes, .Notes(nil), _):
            self.state = .None

        // Select un-selected button
        case let (.Digit(digit), .None, nil),
             let (.Digit(digit), .Digit, _):
            self.state = .Digit(digit)

        case (.Notes, .None, _):
            self.state = .Notes(nil)

        // Switch notes on and off
        case let (.Digit(pressed), .Notes(.some(selected)), _) where pressed == selected:
            self.state = .Notes(nil)

        case let (.Notes, .Digit(digit), _),
             let (.Digit(digit), .Notes, _):
            self.state = .Notes(digit)

        case let (.Notes, .Notes(.some(digit)), _):
            self.state = .Digit(digit)
        }
    }

    private func modify(cell: Board.Location, to newValue: Board.Cell.Value) {
        guard let value = self.boardContainer.board[cell]?.value else {
            return
        }

        let finalValue: Board.Cell.Value

        switch (value, newValue) {
        // Remove current digit
        case let (.Value(digit), .Value(newDigit)) where digit == newDigit:
            finalValue = .Empty

        // Add note
        case let (.Note(notes), .Note(newNotes)) where notes.isDisjoint(with: newNotes):
            finalValue = .Note(notes.union(newNotes))

        // Remove note
        case let (.Note(notes), .Note(newNotes)) where notes.isSuperset(of: newNotes):
            finalValue = .Note(notes.subtracting(newNotes))

        // Add digit/note to empty cell, or overwrite current digit with new digit/note
        case (.Empty, _), (.Value, _), (.Note, _):
            finalValue = newValue
        }

        if finalValue != value {
            DispatchQueue.main.async {
                self.boardContainer.objectWillChange.send()
                self.boardContainer.board[cell]?.value = finalValue
            }
        }
    }
}

#if DEBUG
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
