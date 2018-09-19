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
    {:ok, board} = Board.starting_position() |> IO.inspect() |> Board.move(:e2, :e4) |> IO.inspect()

    assert Board.piece_at(board, :e4) == Piece.white_pawn()
    assert Board.piece_at(board, :e2) == nil
  end
end
