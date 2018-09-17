defmodule Chess.Format.Ascii do
  alias Chess.Board
  alias Chess.Piece

  def to_s(board) do
    "#{top()}#{rank_strings(board)}#{bottom()}"
  end

  defp files do
    ~w[a b c d e f g h]a
  end

  defp piece_symbols(board) do
    for rank <- 8..1,
        file <- files() do
      " #{Board.piece_at(board, file, rank) |> Piece.symbol()} "
    end
  end

  defp rank_strings(board) do
    board
    |> piece_symbols()
    |> Enum.chunk_every(8)
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.zip(8..1)
    |> Enum.map(fn {each, index} -> "#{index} | #{each} |\n" end)
    |> Enum.join("")
  end

  defp border do
    "+--------------------------+"
  end

  defp top do
    "\n\n  #{border()}\n"
  end

  defp bottom do
    "  #{border()}\n     a  b  c  d  e  f  g  h\n\n"
  end
end
