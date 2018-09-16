defmodule Chess.Piece do
  defstruct [:role, :color]

  alias Chess.Piece

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
end
