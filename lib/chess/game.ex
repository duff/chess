defmodule Chess.Game do
  use GenServer

  alias Chess.{Board, Game, Rules, Position, Piece, Color}

  @derive {Inspect, except: ~w(moves)a}

  defstruct board: Board.starting_position(),
            moves: [],
            black: nil,
            white: nil,
            rules: Rules.new(),
            status: nil,
            id: nil

  def start_link() do
    start_genserver(RandomBytes.base62())
  end

  def start_link(game_id) do
    case GenServer.whereis(via_tuple(game_id)) do
      nil -> start_genserver(game_id)
      existing -> {:ok, existing}
    end
  end

  def add_player(game, username, color) do
    GenServer.call(game, {:add_player, username, color})
  end

  def move(game, username, from, to) do
    GenServer.call(game, {:move, username, from, to})
  end

  def via_tuple(id) do
    {:via, Registry, {Registry.Game, id}}
  end

  defp start_genserver(id) do
    GenServer.start_link(__MODULE__, %Game{id: id}, name: via_tuple(id))
  end

  defp update_rules(state_data, rules), do: %{state_data | rules: rules}

  defp update_game(state_data, move, status) do
    %{state_data | board: move.after_board, status: status, moves: [move | state_data.moves]}
  end

  defp reply_success(state_data, reply), do: {:reply, reply, state_data}

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

  @impl true
  def init(game) do
    {:ok, game}
  end

  @impl true
  def handle_call({:add_player, username, color}, _from, state_data) when color in ~w[white black]a do
    with {:ok, rules} <- Rules.check(state_data.rules, {:add_player, color}),
         {:ok} <- add_player_allowed?(state_data, username, color) do
      state_data
      |> Map.replace!(color, username)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      {:error, message} -> {:reply, {:error, message}, state_data}
    end
  end

  @impl true
  def handle_call({:move, username, from, to}, _from, state_data) do
    with {:ok, color} <- color(state_data, username),
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
end
