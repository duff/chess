defmodule Chess.Format.AsciiTest do
  use ExUnit.Case

  alias Chess.Board
  alias Chess.Format.Ascii

  test "to_s" do
    expected = """


      +--------------------------+
    8 |  r  n  b  q  k  b  n  r  |
    7 |  p  p  p  p  p  p  p  p  |
    6 |  .  .  .  .  .  .  .  .  |
    5 |  .  .  .  .  .  .  .  .  |
    4 |  .  .  .  .  .  .  .  .  |
    3 |  .  .  .  .  .  .  .  .  |
    2 |  P  P  P  P  P  P  P  P  |
    1 |  R  N  B  Q  K  B  N  R  |
      +--------------------------+
         a  b  c  d  e  f  g  h

    """

    board = Board.starting_position()
    assert expected == Ascii.to_s(board)
  end
end
