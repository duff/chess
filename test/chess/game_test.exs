defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.{Game, Board, Piece, Move, Position}

  test "board starts out in the right position" do
    assert %Game{}.board == Board.starting_position()
  end

  test "move successful" do
    {:ok, game} = %Game{} |> Game.move(:e2, :e4)

    assert Board.piece(game.board, Position.e4()) == Piece.white_pawn()
    assert Board.piece(game.board, Position.e2()) == nil
    assert [%Move{from: %Position{file: :e, rank: 2}, to: %Position{file: :e, rank: 4}}] = game.moves
  end

  test "move unsuccessful if the Board disallows it" do
    {:error, message} = %Game{} |> Game.move(:e2, :e2)
    assert message == "That is not a legal move."
  end
end
