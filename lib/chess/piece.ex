defmodule Chess.Piece do
  defstruct [:role, :color]

  alias Chess.Piece

  def symbol(p = %Piece{role: :knight}), do: colorize_symbol("n", p)

  def symbol(p = %Piece{role: role}) do
    role
    |> Atom.to_string()
    |> String.first()
    |> colorize_symbol(p)
  end

  def symbol(_piece) do
    "."
  end

  def white_pawn do
    %Piece{role: :pawn, color: :white}
  end

  def white_rook do
    %Piece{role: :rook, color: :white}
  end

  def white_knight do
    %Piece{role: :knight, color: :white}
  end

  def white_bishop do
    %Piece{role: :bishop, color: :white}
  end

  def white_queen do
    %Piece{role: :queen, color: :white}
  end

  def white_king do
    %Piece{role: :king, color: :white}
  end

  def black_pawn do
    %Piece{role: :pawn, color: :black}
  end

  def black_rook do
    %Piece{role: :rook, color: :black}
  end

  def black_knight do
    %Piece{role: :knight, color: :black}
  end

  def black_bishop do
    %Piece{role: :bishop, color: :black}
  end

  def black_queen do
    %Piece{role: :queen, color: :black}
  end

  def black_king do
    %Piece{role: :king, color: :black}
  end

  defp colorize_symbol(symbol, %Piece{color: :white}) do
    String.upcase(symbol)
  end

  defp colorize_symbol(symbol, _), do: symbol
end
