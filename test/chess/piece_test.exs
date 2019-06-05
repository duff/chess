defmodule Chess.PieceTest do
  use ExUnit.Case, async: true

  alias Chess.Piece

  test "symbol" do
    assert Piece.symbol(Piece.white_knight()) == "N"
    assert Piece.symbol(Piece.black_knight()) == "n"

    assert Piece.symbol(Piece.white_pawn()) == "P"
    assert Piece.symbol(Piece.black_pawn()) == "p"

    assert Piece.symbol(Piece.white_rook()) == "R"
    assert Piece.symbol(Piece.black_rook()) == "r"
  end
end
