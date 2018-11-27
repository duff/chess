defmodule Chess.BoardTest do
  use ExUnit.Case

  alias Chess.{Board, Piece, Position, Move}

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
      assert_moves(board, :d4, ~w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4]a)

      board = %Board{a1: Piece.white_rook()}
      assert_moves(board, :a1, ~w[a2 a3 a4 a5 a6 a7 a8 b1 c1 d1 e1 f1 g1 h1]a)
    end

    test "bishop" do
      board = %Board{d4: Piece.white_bishop()}
      assert_moves(board, :d4, ~w[a1 a7 b2 b6 c3 c5 e5 e3 f6 f2 g7 g1 h8]a)

      board = %Board{a1: Piece.white_bishop()}
      assert_moves(board, :a1, ~w[b2 c3 d4 e5 f6 g7 h8]a)
    end

    test "king" do
      board = %Board{d4: Piece.white_king()}
      assert_moves(board, :d4, ~w[e4 c4 d5 d3 e5 e3 c3 c5]a)

      board = %Board{a1: Piece.white_king()}
      assert_moves(board, :a1, ~w[b1 a2 b2]a)
    end

    test "queen" do
      board = %Board{d4: Piece.white_queen()}
      assert_moves(board, :d4, ~w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4 a1 a7 b2 b6 c3 c5 e5 e3 f6 f2 g7 g1 h8]a)

      board = %Board{a1: Piece.white_queen()}
      assert_moves(board, :a1, ~w[a2 a3 a4 a5 a6 a7 a8 b1 c1 d1 e1 f1 g1 h1 b2 c3 d4 e5 f6 g7 h8]a)
    end

    test "knight" do
      board = %Board{d4: Piece.white_knight()}
      assert_moves(board, :d4, ~w[b5 b3 f5 f3 c6 c2 e6 e2]a)

      board = %Board{a1: Piece.white_knight()}
      assert_moves(board, :a1, ~w[c2 b3]a)
    end
  end

  describe "white pawn positions" do
    test "from 2nd rank" do
      board = %Board{d2: Piece.white_pawn()}
      assert_moves(board, :d2, ~w[d4 d3]a)
    end

    test "from a rank greater than the 2nd rank" do
      board = %Board{d3: Piece.white_pawn()}
      assert_moves(board, :d3, ~w[d4]a)
    end

    test "from the top rank" do
      board = %Board{d8: Piece.white_pawn()}
      assert_moves(board, :d8, ~w[]a)
    end

    test "captures" do
      board = %Board{d3: Piece.white_pawn(), e4: Piece.black_bishop()}
      assert_moves(board, :d3, ~w[d4 e4]a)

      board = %Board{d2: Piece.white_pawn(), e3: Piece.black_bishop(), c3: Piece.black_queen()}
      assert_moves(board, :d2, ~w[d3 d4 e3 c3]a)
    end
  end

  describe "black pawn positions" do
    test "from 7th rank" do
      board = %Board{d7: Piece.black_pawn()}
      assert_moves(board, :d7, ~w[d6 d5]a)
    end

    test "from a rank less than the 7th rank" do
      board = %Board{d6: Piece.black_pawn()}
      assert_moves(board, :d6, ~w[d5]a)
    end

    test "from the bottom rank" do
      board = %Board{d1: Piece.black_pawn()}
      assert_moves(board, :d1, ~w[]a)
    end

    test "captures" do
      board = %Board{d6: Piece.black_pawn(), e5: Piece.white_rook()}
      assert_moves(board, :d6, ~w[d5 e5]a)

      board = %Board{d7: Piece.black_pawn(), e6: Piece.white_knight(), c6: Piece.white_bishop()}
      assert_moves(board, :d7, ~w[d6 d5 e6 c6]a)
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

    assert_moves(board, :d4, ~w[c5 e5 e3]a)
  end

  test "bishop positions when blocked by opponent color" do
    board = %Board{
      d4: Piece.white_bishop(),
      f6: Piece.black_rook(),
      f2: Piece.black_pawn(),
      c3: Piece.black_pawn(),
      b6: Piece.black_queen()
    }

    assert_moves(board, :d4, ~w[b6 c3 c5 e5 e3 f2 f6]a)
  end

  test "rook positions when blocked by own color" do
    board = %Board{
      d4: Piece.white_rook(),
      g4: Piece.white_rook(),
      d2: Piece.white_pawn(),
      a4: Piece.white_knight(),
      d7: Piece.white_queen()
    }

    assert_moves(board, :d4, ~w[d3 d5 d6 b4 c4 e4 f4]a)
  end

  test "rook positions when blocked by opponent color" do
    board = %Board{
      d4: Piece.white_rook(),
      g4: Piece.black_rook(),
      d2: Piece.black_pawn(),
      a4: Piece.black_knight(),
      d7: Piece.black_queen()
    }

    assert_moves(board, :d4, ~w[a4 d2 d3 d5 d6 d7 b4 c4 e4 f4 g4]a)
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

    assert_moves(board, :d4, ~w[c5 e5 e3 d3 d5 d6 b4 c4 e4 f4]a)
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

    assert_moves(board, :d4, ~w[b6 c3 c5 e5 e3 f2 f6 a4 d2 d3 d5 d6 d7 b4 c4 e4 f4 g4]a)
  end

  test "king positions when blocked by own color" do
    board = %Board{
      f6: Piece.black_king(),
      f7: Piece.black_queen(),
      f5: Piece.black_bishop(),
      g7: Piece.black_bishop()
    }

    assert_moves(board, :f6, ~w[g6 g5 e5 e6 e7]a)
  end

  test "king positions when blocked by opponent color" do
    board = %Board{
      h8: Piece.black_king(),
      h7: Piece.white_queen(),
      g8: Piece.white_bishop()
    }

    assert_moves(board, :h8, ~w[g7 g8 h7]a)
  end

  test "pawn positions when blocked by own color vertically" do
    board = %Board{
      d2: Piece.white_pawn(),
      d4: Piece.white_queen()
    }

    assert_moves(board, :d2, ~w[d3]a)
  end

  test "pawn positions when blocked by opponent color vertically" do
    board = %Board{
      d2: Piece.white_pawn(),
      d4: Piece.black_queen()
    }

    assert_moves(board, :d2, ~w[d3]a)
  end

  test "knight positions when blocked by own color" do
    board = %Board{
      b1: Piece.white_knight(),
      a3: Piece.white_queen(),
      c3: Piece.white_bishop()
    }

    assert_moves(board, :b1, ~w[d2]a)
  end

  test "knight positions when blocked by opponent color" do
    board = %Board{
      b1: Piece.white_knight(),
      a3: Piece.black_queen(),
      c3: Piece.black_bishop()
    }

    assert_moves(board, :b1, ~w[d2 a3 c3]a)
  end

  # test "positions should not allow you to move into check" do
  #   flunk "Finish this"
  # end

  test "occupied_positions" do
    board = %Board{
      d4: Piece.white_queen(),
      f6: Piece.black_rook(),
      f2: Piece.black_pawn(),
      c3: Piece.black_pawn(),
      b6: Piece.white_bishop()
    }

    assert Board.occupied_positions(board, :white) == position_set(~w[b6 d4]a)
    assert Board.occupied_positions(board, :black) == position_set(~w[f6 f2 c3]a)
  end

  describe "status" do
    test "{:in_progress}" do
      assert {:ok, {:in_progress}} == Board.status(Board.starting_position(), :white)
      assert {:ok, {:in_progress}} == Board.status(Board.starting_position(), :black)
    end

    test "{:in_check, :black}" do
      board = %Board{
        d4: Piece.white_queen(),
        d7: Piece.black_king()
      }

      assert {:ok, {:in_check, :black}} == Board.status(board, :black)
    end

    test "{:in_check, :white}" do
      board = %Board{
        d4: Piece.black_queen(),
        d7: Piece.white_king()
      }

      assert {:ok, {:in_check, :white}} == Board.status(board, :white)
    end

    test "{:in_checkmate, :black}" do
      board = %Board{
        a8: Piece.black_king(),
        a4: Piece.white_queen(),
        b4: Piece.white_rook()
      }

      assert {:ok, {:in_checkmate, :black}} == Board.status(board, :black)
    end

    test "{:in_checkmate, :white}" do
      board = %Board{
        a8: Piece.white_king(),
        a4: Piece.black_queen(),
        b4: Piece.black_rook()
      }

      assert {:ok, {:in_checkmate, :white}} == Board.status(board, :white)
    end

    test "can block the check" do
      board = %Board{
        a8: Piece.black_king(),
        a4: Piece.white_queen(),
        b4: Piece.white_rook(),
        d7: Piece.black_rook()
      }

      assert {:ok, {:in_check, :black}} == Board.status(board, :black)
    end

    test "{:stalemate, :white}" do
      board = %Board{
        a8: Piece.white_king(),
        e7: Piece.black_queen(),
        b4: Piece.black_rook()
      }

      assert {:ok, {:stalemate, :white}} == Board.status(board, :white)
      assert {:ok, {:in_progress}} == Board.status(board, :black)
    end

    test "{:stalemate, :black}" do
      board = %Board{
        a8: Piece.black_king(),
        e7: Piece.white_queen(),
        b4: Piece.white_rook()
      }

      assert {:ok, {:stalemate, :black}} == Board.status(board, :black)
      assert {:ok, {:in_progress}} == Board.status(board, :white)
    end
  end

  defp assert_moves(board, from_position_name, expected_position_names) do
    from_position = Position.for(from_position_name)
    expected_moves = move_set(expected_position_names, board, from_position)
    assert Board.possible_moves(board, from_position) == expected_moves
  end

  defp move_set(position_names, board, from_position) do
    position_names
    |> Enum.map(&Move.new(board, from_position, Position.for(&1)))
    |> MapSet.new()
  end

  defp position_set(position_names) do
    position_names
    |> Enum.map(&Position.for(&1))
    |> MapSet.new()
  end
end
