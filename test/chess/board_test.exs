defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Piece

  test "starting_position" do
    board = Board.starting_position()

    assert board.b2 == Piece.white_pawn()
    assert board.g1 == Piece.white_knight()
    assert board.f8 == Piece.black_bishop()
    assert board.a7 == Piece.black_pawn()

    assert board.a3 == nil
  end

  test "move successful" do
    {:ok, move} = Board.starting_position() |> Board.move(:e2, :e4)

    assert move.from == :e2
    assert move.to == :e4
    assert move.captured == nil
    assert move.before_board.e2 == Piece.white_pawn()
    assert move.before_board.e4 == nil
    assert move.piece == Piece.white_pawn()
    assert move.captured == nil

    assert move.after_board.e2 == nil
    assert move.after_board.e4 == Piece.white_pawn()
  end

  test "moving the same place - fail" do
    {:error, message} = Board.starting_position() |> Board.move(:e2, :e2)
    assert message == "Unable to move to the same place."
  end

  test "moving to a square occupied by the same color - fail" do
    {:error, message} = Board.starting_position() |> Board.move(:e2, :d2)
    assert message == "Unable to move to a position occupied by your own color."
  end
end
