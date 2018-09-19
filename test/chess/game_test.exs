defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Game
  alias Chess.Board
  alias Chess.Piece

  test "board starts out in the right position" do
    assert %Game{}.board == Board.starting_position()
  end

  test "move successful" do
    {:ok, game} = %Game{} |> Game.move(:e2, :e4)

    assert Board.piece_at(game.board, :e4) == Piece.white_pawn()
    assert Board.piece_at(game.board, :e2) == nil
  end

  test "move failed" do
    # {:error, message} = %Game{} |> Game.move(:e2, :e2)
    # assert message == "Not a legal move"
  end
end
