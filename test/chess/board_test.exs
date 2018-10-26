defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.{Board, Piece, Position}

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

    assert move.from == Position.e2()
    assert move.to == Position.e4()
    assert move.captured == nil
    assert move.before_board.e2 == Piece.white_pawn()
    assert move.before_board.e4 == nil
    assert move.piece == Piece.white_pawn()
    assert move.captured == nil

    assert move.after_board.e2 == nil
    assert move.after_board.e4 == Piece.white_pawn()
  end

  describe "move failures" do
    test "moving to the same place" do
      {:error, message} = Board.starting_position() |> Board.move(:e2, :e2)
      assert message == "That is not a legal move."
    end

    test "moving to a square occupied by the same color" do
      {:error, message} = Board.starting_position() |> Board.move(:e2, :d2)
      assert message == "That is not a legal move."
    end

    test "moving a piece to an unreachable position based on the piece and board" do
      {:error, message} = Board.starting_position() |> Board.move(:d2, :g6)
      assert message == "That is not a legal move."
    end

    test "moving to a non-existent position" do
      {:error, message} = Board.starting_position() |> Board.move(:d2, :z6)
      assert message == "Invalid position."
    end

    test "moving from a non-existent position" do
      {:error, message} = Board.starting_position() |> Board.move(:z5, :d4)
      assert message == "Invalid position."
    end

    test "moving from a position that has no piece" do
      {:error, message} = Board.starting_position() |> Board.move(:e5, :e6)
      assert message == "That is not a legal move."
    end
  end

  describe "basic positions" do
    test "rook" do
      board = %Board{d4: Piece.white_rook()}
      assert_positions(board, :d4, ~w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4]a)

      board = %Board{a1: Piece.white_rook()}
      assert_positions(board, :a1, ~w[a2 a3 a4 a5 a6 a7 a8 b1 c1 d1 e1 f1 g1 h1]a)
    end

    test "bishop" do
      board = %Board{d4: Piece.white_bishop()}
      assert_positions(board, :d4, ~w[a1 a7 b2 b6 c3 c5 e5 e3 f6 f2 g7 g1 h8]a)

      board = %Board{a1: Piece.white_bishop()}
      assert_positions(board, :a1, ~w[b2 c3 d4 e5 f6 g7 h8]a)
    end

    test "king" do
      board = %Board{d4: Piece.white_king()}
      assert_positions(board, :d4, ~w[e4 c4 d5 d3 e5 e3 c3 c5]a)

      board = %Board{a1: Piece.white_king()}
      assert_positions(board, :a1, ~w[b1 a2 b2]a)
    end

    test "queen" do
      board = %Board{d4: Piece.white_queen()}
      assert_positions(board, :d4, ~w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4 a1 a7 b2 b6 c3 c5 e5 e3 f6 f2 g7 g1 h8]a)

      board = %Board{a1: Piece.white_queen()}
      assert_positions(board, :a1, ~w[a2 a3 a4 a5 a6 a7 a8 b1 c1 d1 e1 f1 g1 h1 b2 c3 d4 e5 f6 g7 h8]a)
    end

    test "knight" do
      board = %Board{d4: Piece.white_knight()}
      assert_positions(board, :d4, ~w[b5 b3 f5 f3 c6 c2 e6 e2]a)

      board = %Board{a1: Piece.white_knight()}
      assert_positions(board, :a1, ~w[c2 b3]a)
    end
  end

  describe "white pawn positions" do
    test "from 2nd rank" do
      board = %Board{d2: Piece.white_pawn()}
      assert_positions(board, :d2, ~w[d4 d3]a)
    end

    test "from a rank greater than the 2nd rank" do
      board = %Board{d3: Piece.white_pawn()}
      assert_positions(board, :d3, ~w[d4]a)
    end

    test "from the top rank" do
      board = %Board{d8: Piece.white_pawn()}
      assert_positions(board, :d8, ~w[]a)
    end

    test "captures" do
      board = %Board{d3: Piece.white_pawn(), e4: Piece.black_bishop()}
      assert_positions(board, :d3, ~w[d4 e4]a)

      board = %Board{d2: Piece.white_pawn(), e3: Piece.black_bishop(), c3: Piece.black_queen()}
      assert_positions(board, :d2, ~w[d3 d4 e3 c3]a)
    end
  end

  describe "black pawn positions" do
    test "from 7th rank" do
      board = %Board{d7: Piece.black_pawn()}
      assert_positions(board, :d7, ~w[d6 d5]a)
    end

    test "from a rank less than the 7th rank" do
      board = %Board{d6: Piece.black_pawn()}
      assert_positions(board, :d6, ~w[d5]a)
    end

    test "from the bottom rank" do
      board = %Board{d1: Piece.black_pawn()}
      assert_positions(board, :d1, ~w[]a)
    end

    test "captures" do
      board = %Board{d6: Piece.black_pawn(), e5: Piece.white_rook()}
      assert_positions(board, :d6, ~w[d5 e5]a)

      board = %Board{d7: Piece.black_pawn(), e6: Piece.white_knight(), c6: Piece.white_bishop()}
      assert_positions(board, :d7, ~w[d6 d5 e6 c6]a)
    end
  end

  test "bishop positions when blocked by own color" do
    board = %Board{
      d4: Piece.white_bishop(),
      f6: Piece.white_rook(),
      f2: Piece.white_pawn(),
      c3: Piece.white_knight(),
      b6: Piece.white_queen()
    }

    assert_positions(board, :d4, ~w[c5 e5 e3]a)
  end

  test "bishop positions when blocked by opponent color" do
    board = %Board{
      d4: Piece.white_bishop(),
      f6: Piece.black_rook(),
      f2: Piece.black_pawn(),
      c3: Piece.black_pawn(),
      b6: Piece.black_queen()
    }

    assert_positions(board, :d4, ~w[b6 c3 c5 e5 e3 f2 f6]a)
  end

  test "rook positions when blocked by own color" do
    board = %Board{
      d4: Piece.white_rook(),
      g4: Piece.white_rook(),
      d2: Piece.white_pawn(),
      a4: Piece.white_knight(),
      d7: Piece.white_queen()
    }

    assert_positions(board, :d4, ~w[d3 d5 d6 b4 c4 e4 f4]a)
  end

  test "rook positions when blocked by opponent color" do
    board = %Board{
      d4: Piece.white_rook(),
      g4: Piece.black_rook(),
      d2: Piece.black_pawn(),
      a4: Piece.black_knight(),
      d7: Piece.black_queen()
    }

    assert_positions(board, :d4, ~w[a4 d2 d3 d5 d6 d7 b4 c4 e4 f4 g4]a)
  end

  test "queen positions when blocked by own color" do
    board = %Board{
      d4: Piece.white_queen(),
      g4: Piece.white_rook(),
      d2: Piece.white_pawn(),
      a4: Piece.white_knight(),
      d7: Piece.white_pawn(),
      f6: Piece.white_rook(),
      f2: Piece.white_pawn(),
      c3: Piece.white_knight(),
      b6: Piece.white_pawn()
    }

    assert_positions(board, :d4, ~w[c5 e5 e3 d3 d5 d6 b4 c4 e4 f4]a)
  end

  test "queen positions when blocked by opponent color" do
    board = %Board{
      d4: Piece.white_queen(),
      f6: Piece.black_rook(),
      f2: Piece.black_pawn(),
      c3: Piece.black_pawn(),
      b6: Piece.black_bishop(),
      g4: Piece.black_rook(),
      d2: Piece.black_pawn(),
      a4: Piece.black_knight(),
      d7: Piece.black_queen()
    }

    assert_positions(board, :d4, ~w[b6 c3 c5 e5 e3 f2 f6 a4 d2 d3 d5 d6 d7 b4 c4 e4 f4 g4]a)
  end

  defp assert_positions(board, from_position_name, expected_position_names) do
    expected_positions = expected_position_names |> Enum.map(&Position.for(&1)) |> MapSet.new()
    from_position = Position.for(from_position_name)
    assert Board.possible_positions(board, from_position) == {:ok, expected_positions}
  end
end
