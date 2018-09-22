defmodule Chess.Move do
  defstruct [:piece, :from, :to, :before_board, :after_board, :captured]

  # def execute(board, from, to) do
  #   from_piece = Board.piece_at(board, from)
  #   to_piece = Board.piece_at(board, to)

  # end
end
