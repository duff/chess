defmodule Chess.Game do
  alias Chess.{Board, Game, Rules, Position, Piece, Color}

  @derive {Inspect, except: ~w(moves)a}

  defstruct board: Board.starting_position(),
            moves: [],
            black: nil,
            white: nil,
            rules: Rules.new(),
            status: nil,
            id: nil

  def new do
    %Game{}
  end

  def add_player(game, username, color) when color in ~w[white black]a do
    with {:ok, rules} <- Rules.check(game.rules, {:add_player, color}),
         {:ok} <- add_player_allowed?(game, username, color) do
      game
      |> Map.replace!(color, username)
      |> update_rules(rules)
      |> reply_success()
    else
      {:error, message} -> {:error, message}
    end
  end

  def move(game, username, from, to) do
    with {:ok, color} <- color(game, username),
         {:ok, rules} <- Rules.check(game.rules, {:move, color}),
         {:ok, from_position} <- Position.new(from),
         {:ok} <- moving_own_piece(color, game.board, from_position),
         {:ok, move} <- Board.move(game.board, from, to),
         {:ok, status} <- Board.status(move.after_board, Color.opposite(color)),
         {:ok, rules} <- Rules.check(rules, {:endgame_check, status}) do
      game
      |> update_game(move, status)
      |> update_rules(rules)
      |> reply_success()
    else
      {:error, message} -> {:error, message}
    end
  end

  defp update_rules(game, rules), do: %{game | rules: rules}

  defp update_game(state_data, move, status) do
    %{state_data | board: move.after_board, status: status, moves: [move | state_data.moves]}
  end

  defp reply_success(game), do: {:ok, game}

  defp add_player_allowed?(%Game{black: username}, username, :white) do
    {:error, "The same player cannot play both sides of the board."}
  end

  defp add_player_allowed?(%Game{white: username}, username, :black) do
    {:error, "The same player cannot play both sides of the board."}
  end

  defp add_player_allowed?(_, _, _) do
    {:ok}
  end

  defp color(%Game{black: username}, username) do
    {:ok, :black}
  end

  defp color(%Game{white: username}, username) do
    {:ok, :white}
  end

  defp color(_, _) do
    {:error, "Unable to make a move if you're not playing the game."}
  end

  defp moving_own_piece(turn_color, board, from_position) do
    case Board.piece(board, from_position) do
      %Piece{color: ^turn_color} -> {:ok}
      nil -> {:error, "There is no piece at that position."}
      _ -> {:error, "Unable to move opponent's piece."}
    end
  end
end
