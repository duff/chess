defmodule Chess.Game do
  alias Chess.Board

  defstruct board: Board.starting_position(), moves: []

  def move(game, from, to) do
    case Board.move(game.board, from, to) do
      {:ok, move} ->
        {:ok, %{game | board: move.after_board, moves: [move | game.moves]}}

      {:error, message} ->
        {:error, message}
    end
  end
end
