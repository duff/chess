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
  @reverse_file_index Enum.zip(1..8, @files) |> Map.new()

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

  def positions(board, from) do
    from_piece = Board.piece(board, from)
    do_positions(board, from_piece, Position.for(from))
  end

  defp do_positions(_board, %Piece{role: :rook}, position) do
    rook_positions_names(position)
  end

  defp do_positions(board, %Piece{role: :bishop}, position) do
    bishop_position_names(board, position)
  end

  defp do_positions(board, %Piece{role: :queen}, position) do
    rook_positions_names(position) ++ bishop_position_names(board, position)
  end

  defp do_positions(_board, %Piece{role: :king}, position) do
    [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, -1], [-1, 1]]
    |> relative_position_names(position)
    |> delete_invalid()
  end

  defp do_positions(_board, %Piece{role: :knight}, position) do
    [[-2, 1], [-2, -1], [2, 1], [2, -1], [-1, 2], [-1, -2], [1, 2], [1, -2]]
    |> relative_position_names(position)
    |> delete_invalid()
  end

  defp do_positions(board, piece = %Piece{role: :pawn}, position) do
    forward_positions(piece, position)
    |> relative_position_names(position)
    |> delete_invalid()
    |> Kernel.++(pawn_capture_position_names(board, piece, position))
  end

  defp forward_positions(%Piece{color: :white}, %Chess.Position{rank: 2}), do: [[0, 1], [0, 2]]
  defp forward_positions(%Piece{color: :white}, _), do: [[0, 1]]
  defp forward_positions(%Piece{color: :black}, %Chess.Position{rank: 7}), do: [[0, -1], [0, -2]]
  defp forward_positions(%Piece{color: :black}, _), do: [[0, -1]]

  defp rook_positions_names(position) do
    column_position_names(position) ++ row_position_names(position)
  end

  defp bishop_position_names(board, position) do
    yo_positions_names(board, position, 1, 1) ++
      yo_positions_names(board, position, 1, -1) ++
      yo_positions_names(board, position, -1, -1) ++ yo_positions_names(board, position, -1, 1)
  end

  defp blah(position_names, board, position) do
    %Piece{color: moving_piece_color} = Board.piece(board, position)

    position_names
    |> Enum.reduce_while([], fn each, acc ->
      # piece = Board.piece(board, each)
      # cond do
      #   piece == nil ->
      #     {:cont, acc ++ [each]}
      #   piece.color != Board.piece(board, position).color ->
      #     {:halt, acc ++ [each]}
      #   true ->
      #     {:halt, acc}
      # end
      case Board.piece(board, each) do
        nil -> {:cont, acc ++ [each]}
        %Piece{color: ^moving_piece_color} -> {:halt, acc}
        _ -> {:halt, acc ++ [each]}
      end

      # cond do
      #   piece == nil ->
      #     {:cont, acc ++ [each]}
      #   piece.color != Board.piece(board, position).color ->
      #     {:halt, acc ++ [each]}
      #   true ->
      #     {:halt, acc}
      # end
    end)
  end

  defp yo_positions_names(board, position, file_multiple, rank_multiple) do
    Enum.map(1..7, &relative_position_name(position, &1 * file_multiple, &1 * rank_multiple))
    |> delete_invalid
    |> blah(board, position)
  end

  defp pawn_capture_position_names(board, piece, position) do
    possible_pawn_capture_position_names(piece)
    |> relative_position_names(position)
    |> delete_invalid()
    |> Enum.filter(fn each -> capturable(piece, piece(board, each)) end)
  end

  defp possible_pawn_capture_position_names(%Piece{color: :white}) do
    [[1, 1], [-1, 1]]
  end

  defp possible_pawn_capture_position_names(%Piece{color: :black}) do
    [[1, -1], [-1, -1]]
  end

  defp capturable(_, nil), do: false
  defp capturable(%Piece{color: same_color}, %Piece{color: same_color}), do: false
  defp capturable(_, _), do: true

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

  defp relative_position_names(deltas, position) do
    Enum.map(deltas, fn [file, rank] ->
      relative_position_name(position, file, rank)
    end)
  end

  defp relative_position_name(position, file_delta, rank_delta) do
    Position.name(
      @reverse_file_index[@file_index[position.file] + file_delta],
      position.rank + rank_delta
    )
  end
end

defimpl Inspect, for: Chess.Board do
  def inspect(board, _opts) do
    Chess.Format.Ascii.to_s(board)
  end
end
