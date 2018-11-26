defmodule Chess.Game do
  use GenServer

  alias Chess.{Board, Game, Rules, Position, Piece, Color}

  defstruct board: Board.starting_position(),
            moves: [],
            black: nil,
            white: nil,
            rules: Rules.new(),
            status: nil,
            id: nil

  def start_link() do
    game = %Game{id: RandomBytes.base62()}
    GenServer.start_link(__MODULE__, game, name: via_tuple(game.id))
  end

  def add_player(game, user, color) when color in ~w[white black]a do
    GenServer.call(game, {:add_player, user, color})
  end

  def move(game, user, from, to) do
    GenServer.call(game, {:move, user, from, to})
  end

  def via_tuple(id) do
    {:via, Registry, {Registry.Game, id}}
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:add_player, user, color}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, {:add_player, color}),
         {:ok} <- add_player_allowed?(state_data, user, color) do
      state_data
      |> Map.replace!(color, user)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      {:error, message} -> {:reply, {:error, message}, state_data}
    end
  end

  def handle_call({:move, user, from, to}, _from, state_data) do
    with {:ok, color} <- color(state_data, user),
         {:ok, rules} <- Rules.check(state_data.rules, {:move, color}),
         {:ok, from_position} <- Position.new(from),
         {:ok} <- moving_own_piece(color, state_data.board, from_position),
         {:ok, move} <- Board.move(state_data.board, from, to),
         {:ok, status} <- Board.status(move.after_board, Color.opposite(color)),
         {:ok, rules} <- Rules.check(rules, {:endgame_check, status}) do
      state_data
      |> update_game(move, status)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      {:error, message} -> {:reply, {:error, message}, state_data}
    end
  end

  defp update_rules(state_data, rules), do: %{state_data | rules: rules}

  defp update_game(state_data, move, status) do
    %{state_data | board: move.after_board, status: status, moves: [move | state_data.moves]}
  end

  defp reply_success(state_data, reply), do: {:reply, reply, state_data}

  defp add_player_allowed?(%Game{black: user}, user, :white) do
    {:error, "The same player cannot play both sides of the board."}
  end

  defp add_player_allowed?(%Game{white: user}, user, :black) do
    {:error, "The same player cannot play both sides of the board."}
  end

  defp add_player_allowed?(_, _, _) do
    {:ok}
  end

  defp color(%Game{black: user}, user) do
    {:ok, :black}
  end

  defp color(%Game{white: user}, user) do
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
