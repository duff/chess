defmodule Chess.Game do
  alias Chess.Board

  defstruct board: Board.starting_position()

  def move(game, from, to) do
    case Board.move(game.board, from, to) do
      {:ok, board} -> {:ok, %{game | board: board}}
      {:error, message} -> {:error, message}
    end
  end
end
