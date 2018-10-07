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
  alias Chess.Move

  @files ~w(a b c d e f g h)a
  @ranks 1..8
  @file_index Enum.with_index(@files, 1) |> Map.new()

  def starting_position do
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
    |> struct(initial_white_pawns())
    |> struct(initial_black_pawns())
  end

  def piece(board, file, rank) do
    Map.fetch!(board, Position.name(file, rank))
  end

  def piece(board, position_name) do
    Map.fetch!(board, position_name)
  end

  def move(_board, same_from_to, same_from_to) do
    {:error, "Unable to move to the same place."}
  end

  def move(board, from, to) do
    from_piece = Board.piece(board, from)
    to_piece = Board.piece(board, to)

    case legal?(from_piece, to_piece) do
      :ok -> do_move(board, from, to, from_piece, to_piece)
      {:error, message} -> {:error, message}
    end
  end

  def positions(board, from) do
    from_piece = Board.piece(board, from)
    do_positions(board, from_piece, Position.for(from))
  end

  defp do_positions(_board, %Piece{role: :rook}, position) do
    column_position_names(position) ++ row_position_names(position)
  end

  defp do_positions(_board, %Piece{role: :bishop}, position) do
    diagonal_position_names(position)
  end

  defp do_positions(_board, %Piece{role: :king}, position) do
    adjacent_column_position_names(position)
    |> Kernel.++(adjacent_row_position_names(position))
    |> Kernel.++(adjacent_diagonal_position_names(position))
  end

  defp file_distance(position_name, %Position{file: file}) do
    (@file_index[Position.for(position_name).file] - @file_index[file])
    |> abs
  end

  defp rank_distance(position_name, %Position{rank: rank}) do
    (Position.for(position_name).rank - rank)
    |> abs
  end

  defp diagonal_position_names(position) do
    @files
    |> Enum.map(&diagonal_position_names_for_file(&1, position))
    |> List.flatten()
    |> delete_all(position)
    |> delete_invalid
  end

  defp diagonal_position_names_for_file(destination_file, %Position{file: source_file, rank: source_rank}) do
    distance = @file_index[destination_file] - @file_index[source_file]
    [Position.name(destination_file, source_rank + distance), Position.name(destination_file, source_rank - distance)]
  end

  defp delete_all(list, position) do
    list
    |> Enum.reject(&(&1 == Position.name(position)))
  end

  defp delete_invalid(list) do
    list
    |> Enum.reject(&(!Position.valid?(&1)))
  end

  defp do_move(board, from, to, from_piece, to_piece) do
    after_board = %{board | to => from_piece, from => nil}

    move = %Move{from: from, to: to, before_board: board, after_board: after_board, piece: from_piece, captured: to_piece}
    {:ok, move}
  end

  defp legal?(%Piece{color: same_color}, %Piece{color: same_color}) do
    {:error, "Unable to move to a position occupied by your own color."}
  end

  defp legal?(_, _), do: :ok

  defp initial_white_pawns do
    ~w[a2 b2 c2 d2 e2 f2 g2 h2]a
    |> Map.new(fn key -> {key, Piece.white_pawn()} end)
  end

  defp initial_black_pawns do
    ~w[a7 b7 c7 d7 e7 f7 g7 h7]a
    |> Map.new(fn key -> {key, Piece.black_pawn()} end)
  end

  defp column_position_names(position = %Position{file: file}) do
    @ranks
    |> Enum.map(fn each_rank -> Position.name(file, each_rank) end)
    |> delete_all(position)
  end

  defp row_position_names(position = %Position{rank: rank}) do
    @files
    |> Enum.map(fn each_file -> Position.name(each_file, rank) end)
    |> delete_all(position)
  end

  defp adjacent_column_position_names(position) do
    column_position_names(position)
    |> Enum.filter(&(rank_distance(&1, position) == 1))
  end

  defp adjacent_row_position_names(position) do
    row_position_names(position)
    |> Enum.filter(&(file_distance(&1, position) == 1))
  end

  defp adjacent_diagonal_position_names(position) do
    diagonal_position_names(position)
    |> Enum.filter(&(file_distance(&1, position) == 1))
  end
end

defimpl Inspect, for: Chess.Board do
  def inspect(board, _opts) do
    Chess.Format.Ascii.to_s(board)
  end
end
