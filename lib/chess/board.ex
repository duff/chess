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

  alias Chess.{Piece, Board, Position, Move}

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

  def occupied_positions(board, color) do
    for {key, %Chess.Piece{color: ^color}} <- Map.from_struct(board) do
      key
    end
    |> MapSet.new()
  end

  def move(board, from_position_name, to_position_name) do
    with {:ok, from} <- Position.new(from_position_name),
         {:ok, to} <- Position.new(to_position_name),
         {:ok, possible_positions} <- possible_positions(board, from) do
      if MapSet.member?(possible_positions, to) do
        {:ok, Move.new(board, from, to)}
      else
        {:error, "That is not a legal move."}
      end
    end
  end

  def possible_moves(board, from = %Position{}) do
    {:ok, positions} = possible_positions(board, from)

    positions
    |> Enum.map(&Move.new(board, from, &1))
  end

  def possible_positions(board, from = %Position{}) do
    from_piece = piece(board, from)
    positions(board, from_piece, from)
  end

  defp positions(board, %Piece{role: :rook}, position) do
    {:ok, rook_positions(board, position)}
  end

  defp positions(board, %Piece{role: :bishop}, position) do
    {:ok, bishop_positions(board, position)}
  end

  defp positions(board, %Piece{role: :queen}, position) do
    result = rook_positions(board, position) |> MapSet.union(bishop_positions(board, position))
    {:ok, result}
  end

  defp positions(board, %Piece{role: :king, color: color}, position) do
    result =
      [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
      |> relative_positions(position)
      |> remove_occupied_by(board, color)
      |> MapSet.new()

    {:ok, result}
  end

  defp positions(board, %Piece{role: :knight, color: color}, position) do
    result =
      [[-2, 1], [-2, -1], [2, 1], [2, -1], [-1, 2], [-1, -2], [1, 2], [1, -2]]
      |> relative_positions(position)
      |> remove_occupied_by(board, color)
      |> MapSet.new()

    {:ok, result}
  end

  defp positions(board, piece = %Piece{role: :pawn, color: color}, position) do
    result =
      forward_positions(piece, position)
      |> relative_positions(position)
      |> remove_occupied_by(board, color)
      |> remove_occupied_by(board, opposite(color))
      |> MapSet.new()
      |> MapSet.union(pawn_capture_positions(board, piece, position))

    {:ok, result}
  end

  defp positions(_, _, _), do: {:ok, MapSet.new()}

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

  defp until_piece_found(positions, board, position) do
    %Piece{color: moving_piece_color} = Board.piece(board, position)

    positions
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
    |> column_positions(board, position)
  end

  defp south_positions(board, position) do
    -7..-1
    |> column_positions(board, position)
  end

  defp east_positions(board, position) do
    7..1
    |> row_positions(board, position)
  end

  defp west_positions(board, position) do
    -7..-1
    |> row_positions(board, position)
  end

  defp column_positions(deltas, board, position) do
    deltas
    |> Enum.map(&[0, &1])
    |> relative_positions(position)
    |> until_piece_found(board, position)
    |> MapSet.new()
  end

  defp row_positions(deltas, board, position) do
    deltas
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

  defp remove_occupied_by(positions, board, color) do
    positions
    |> Enum.filter(fn position ->
      case Board.piece(board, position) do
        %Piece{color: ^color} -> false
        _ -> true
      end
    end)
  end

  defp opposite(:black), do: :white
  defp opposite(:white), do: :black
end

defimpl Inspect, for: Chess.Board do
  def inspect(board, _opts) do
    Chess.Format.Ascii.to_s(board)
  end
end
