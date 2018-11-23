defmodule Chess.Move do
  defstruct [:piece, :from, :to, :before_board, :after_board, :captured]
  alias Chess.{Move, Board, Position}

  def new(board, from, to) do
    from_piece = Board.piece(board, from)
    after_board = %{board | Position.name(to) => from_piece, Position.name(from) => nil}

    %Move{from: from, to: to, before_board: board, after_board: after_board, piece: from_piece, captured: Board.piece(board, to)}
  end
end
