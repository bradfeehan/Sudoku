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
        case let .Button(.Digit(digit)):
            self.modify(cell: cell.location, to: digit)
        case .None:
            if self.selection == cell.location {
                self.selection = nil
            } else {
                self.selection = cell.location
            }
        }
    }

    private func handleControlsTap(_ button: ControlsView.Button) {
        switch button {
        case let .Digit(digit):
            if let selection = self.selection {
                self.modify(cell: selection, to: digit)
            } else {
                self.toggleButtonState(button)
            }
        }
    }

    private func modify(cell: Board.Location, to digit: Board.Cell.Digit) {
        let value: Board.Cell.Value
        if self.boardContainer.board[cell]?.value == .Value(digit) {
            value = .Empty
        } else {
            value = .Value(digit)
        }

        DispatchQueue.main.async {
            self.boardContainer.objectWillChange.send()
            self.boardContainer.board[cell]?.value = value
        }
    }

    private func toggleButtonState(_ button: ControlsView.Button) {
        switch self.state {
        case .Button(button):
            self.state = .None
        default:
            self.state = .Button(button)
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
