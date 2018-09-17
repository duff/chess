defmodule Chess.Board do
  defstruct ~w[
    a8 b8 c8 d8 e8 f8 g8 h8
    a7 b7 c7 d7 e7 f7 g7 h7
    a6 b6 c6 d6 e6 f6 g6 h6
    a5 b5 c5 d5 e5 f5 g5 h5
    a4 b4 c4 d4 e4 f4 g4 h4
    a3 b3 c3 d3 e3 f3 g3 h3
    a2 b2 c2 d2 e2 f2 g2 h2
    a1 b1 c1 d1 e1 f1 g1 h1
  ]a

  alias Chess.Piece
  alias Chess.Board
  alias Chess.Position

  def starting_position do
    white_pawns =
      ~w[a2 b2 c2 d2 e2 f2 g2 h2]a
      |> Map.new(fn key -> {key, Piece.white_pawn()} end)

    black_pawns =
      ~w[a7 b7 c7 d7 e7 f7 g7 h7]a
      |> Map.new(fn key -> {key, Piece.black_pawn()} end)

    %Board{
      a1: Piece.white_rook(),
      b1: Piece.white_knight(),
      c1: Piece.white_bishop(),
      d1: Piece.white_queen(),
      e1: Piece.white_king(),
      f1: Piece.white_bishop(),
      g1: Piece.white_knight(),
      h1: Piece.white_rook(),
      a8: Piece.black_rook(),
      b8: Piece.black_knight(),
      c8: Piece.black_bishop(),
      d8: Piece.black_queen(),
      e8: Piece.black_king(),
      f8: Piece.black_bishop(),
      g8: Piece.black_knight(),
      h8: Piece.black_rook()
    }
    |> struct(white_pawns)
    |> struct(black_pawns)
  end

  def piece_at(board, file, rank) do
    Map.fetch!(board, Position.name(file, rank))
  end

  def piece_at(board, position_name) do
    Map.fetch!(board, position_name)
  end
end
