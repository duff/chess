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
    assert Board.positions(board, :d4) == ~w[e4 c4 d5 d3 e5 e3 c3 c5]a

    board = %Board{a1: Piece.white_king()}
    assert Board.positions(board, :a1) == ~w[b1 a2 b2]a
  end

  test "basic queen positions" do
    board = %Board{d4: Piece.white_queen()}
    assert Board.positions(board, :d4) == ~w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4 a1 a7 b2 b6 c3 c5 e5 e3 f6 f2 g7 g1 h8]a

    board = %Board{a1: Piece.white_queen()}
    assert Board.positions(board, :a1) == ~w[a2 a3 a4 a5 a6 a7 a8 b1 c1 d1 e1 f1 g1 h1 b2 c3 d4 e5 f6 g7 h8]a
  end

  test "basic knight positions" do
    board = %Board{d4: Piece.white_knight()}
    assert Board.positions(board, :d4) == ~w[b5 b3 f5 f3 c6 c2 e6 e2]a

    board = %Board{a1: Piece.white_knight()}
    assert Board.positions(board, :a1) == ~w[c2 b3]a
  end

  describe "white pawn positions" do
    test "from 2nd rank" do
      board = %Board{d2: Piece.white_pawn()}
      assert Board.positions(board, :d2) == ~w[d3 d4]a
    end

    test "from a rank greater than the 2nd rank" do
      board = %Board{d3: Piece.white_pawn()}
      assert Board.positions(board, :d3) == ~w[d4]a
    end

    test "captures" do
    end
  end

  describe "black pawn positions" do
    test "from 7th rank" do
      board = %Board{d7: Piece.black_pawn()}
      assert Board.positions(board, :d7) == ~w[d6 d5]a
    end

    test "from a rank less than the 7th rank" do
      board = %Board{d6: Piece.black_pawn()}
      assert Board.positions(board, :d6) == ~w[d5]a
    end

    test "captures" do
    end
  end
end
