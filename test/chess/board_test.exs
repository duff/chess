defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Piece
  # alias Chess.Move

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

  test "basic rook positions" do
    board = %Board{d4: Piece.white_rook()}
    assert Board.positions(board, :d4) == ~w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4]a

    board = %Board{a1: Piece.white_rook()}
    assert Board.positions(board, :a1) == ~w[a2 a3 a4 a5 a6 a7 a8 b1 c1 d1 e1 f1 g1 h1]a
  end

  test "basic bishop positions" do
    board = %Board{d4: Piece.white_bishop()}
    assert Board.positions(board, :d4) == ~w[a1 a7 b2 b6 c3 c5 e5 e3 f6 f2 g7 g1 h8]a

    board = %Board{a1: Piece.white_bishop()}
    assert Board.positions(board, :a1) == ~w[b2 c3 d4 e5 f6 g7 h8]a
  end

  test "basic king positions" do
    board = %Board{d4: Piece.white_king()}
    assert Board.positions(board, :d4) == ~w[d3 d5 c4 e4 c3 c5 e5 e3]a

    board = %Board{a1: Piece.white_king()}
    assert Board.positions(board, :a1) == ~w[a2 b1 b2]a
  end
end
