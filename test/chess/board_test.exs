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

  test "ascii" do
    expected = """


      +------------------------+
    8 | r  n  b  q  k  b  n  r |
    7 | p  p  p  p  p  p  p  p |
    6 | .  .  .  .  .  .  .  . |
    5 | .  .  .  .  .  .  .  . |
    4 | .  .  .  .  .  .  .  . |
    3 | .  .  .  .  .  .  .  . |
    2 | P  P  P  P  P  P  P  P |
    1 | R  N  B  Q  K  B  N  R |
      +------------------------+
        a  b  c  d  e  f  g  h


    """

    board = Board.starting_position()
    assert expected == Board.ascii(board)
  end
end
