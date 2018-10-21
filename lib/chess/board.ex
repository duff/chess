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

  @file_index Enum.with_index(Position.files(), 1) |> Map.new()
  @reverse_file_index Enum.zip(Position.ranks(), Position.files()) |> Map.new()

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
    {:ok, position} = Position.new(file, rank)
    piece(board, position)
  end

  def piece(board, position = %Position{}) do
    Map.fetch!(board, Position.name(position))
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

  def positions(board, from = %Position{}) do
    from_piece = piece(board, from)
    do_positions(board, from_piece, from)
  end

  defp do_positions(board, %Piece{role: :rook}, position) do
    rook_positions(board, position)
  end

  defp do_positions(board, %Piece{role: :bishop}, position) do
    bishop_positions(board, position)
  end

  defp do_positions(board, %Piece{role: :queen}, position) do
    rook_positions(board, position)
    |> MapSet.union(bishop_positions(board, position))
  end

  defp do_positions(_board, %Piece{role: :king}, position) do
    [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
    |> relative_positions(position)
    |> MapSet.new()
  end

  defp do_positions(_board, %Piece{role: :knight}, position) do
    [[-2, 1], [-2, -1], [2, 1], [2, -1], [-1, 2], [-1, -2], [1, 2], [1, -2]]
    |> relative_positions(position)
    |> MapSet.new()
  end

  defp do_positions(board, piece = %Piece{role: :pawn}, position) do
    forward_positions(piece, position)
    |> relative_positions(position)
    |> MapSet.new()
    |> MapSet.union(pawn_capture_positions(board, piece, position))
  end

  defp forward_positions(%Piece{color: :white}, %Chess.Position{rank: 2}), do: [[0, 1], [0, 2]]
  defp forward_positions(%Piece{color: :white}, _), do: [[0, 1]]
  defp forward_positions(%Piece{color: :black}, %Chess.Position{rank: 7}), do: [[0, -1], [0, -2]]
  defp forward_positions(%Piece{color: :black}, _), do: [[0, -1]]

  defp rook_positions(board, position) do
    north_positions(board, position)
    |> MapSet.union(south_positions(board, position))
    |> MapSet.union(east_positions(board, position))
    |> MapSet.union(west_positions(board, position))
  end

  defp bishop_positions(board, position) do
    diagonal_positions(board, position, 1, 1)
    |> MapSet.union(diagonal_positions(board, position, 1, -1))
    |> MapSet.union(diagonal_positions(board, position, -1, -1))
    |> MapSet.union(diagonal_positions(board, position, -1, 1))
  end

  defp until_piece_found(position_names, board, position) do
    %Piece{color: moving_piece_color} = Board.piece(board, position)

    position_names
    |> Enum.reduce_while([], fn each, acc ->
      case Board.piece(board, each) do
        nil -> {:cont, acc ++ [each]}
        %Piece{color: ^moving_piece_color} -> {:halt, acc}
        _ -> {:halt, acc ++ [each]}
      end
    end)
  end

  defp diagonal_positions(board, position, file_multiple, rank_multiple) do
    7..1
    |> Enum.map(&[&1 * file_multiple, &1 * rank_multiple])
    |> relative_positions(position)
    |> until_piece_found(board, position)
    |> MapSet.new()
  end

  defp pawn_capture_positions(board, piece, position) do
    possible_pawn_capture_deltas(piece)
    |> relative_positions(position)
    |> Enum.filter(fn each -> capturable(piece, piece(board, each)) end)
    |> MapSet.new()
  end

  defp possible_pawn_capture_deltas(%Piece{color: :white}) do
    [[1, 1], [-1, 1]]
  end

  defp possible_pawn_capture_deltas(%Piece{color: :black}) do
    [[1, -1], [-1, -1]]
  end

  defp capturable(_, nil), do: false
  defp capturable(%Piece{color: same_color}, %Piece{color: same_color}), do: false
  defp capturable(_, _), do: true

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

  defp north_positions(board, position) do
    7..1
    |> Enum.map(&[0, &1])
    |> relative_positions(position)
    |> until_piece_found(board, position)
    |> MapSet.new()
  end

  defp south_positions(board, position) do
    -7..-1
    |> Enum.map(&[0, &1])
    |> relative_positions(position)
    |> until_piece_found(board, position)
    |> MapSet.new()
  end

  defp east_positions(board, position) do
    7..1
    |> Enum.map(&[&1, 0])
    |> relative_positions(position)
    |> until_piece_found(board, position)
    |> MapSet.new()
  end

  defp west_positions(board, position) do
    -7..-1
    |> Enum.map(&[&1, 0])
    |> relative_positions(position)
    |> until_piece_found(board, position)
    |> MapSet.new()
  end

  defp relative_positions(deltas, position) do
    Enum.reduce(deltas, [], fn [file, rank], acc ->
      case relative_position(position, file, rank) do
        {:ok, new_position} -> [new_position | acc]
        {:error, _} -> acc
      end
    end)
  end

  defp relative_position(position, file_delta, rank_delta) do
    Position.new(@reverse_file_index[@file_index[position.file] + file_delta], position.rank + rank_delta)
  end
end

defimpl Inspect, for: Chess.Board do
  def inspect(board, _opts) do
    Chess.Format.Ascii.to_s(board)
  end
end
