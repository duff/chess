defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.Game
  alias Chess.Board
  alias Chess.Piece
  alias Chess.Move

  test "board starts out in the right position" do
    assert %Game{}.board == Board.starting_position()
  end

  test "move successful" do
    {:ok, game} = %Game{} |> Game.move(:e2, :e4)

    assert Board.piece(game.board, :e4) == Piece.white_pawn()
    assert Board.piece(game.board, :e2) == nil
    assert [%Move{from: :e2, to: :e4}] = game.moves
  end

  test "from and to cannot be the same" do
    {:error, message} = %Game{} |> Game.move(:e2, :e2)
    assert message == "Unable to move to the same place."
  end
end
