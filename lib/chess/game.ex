defmodule Chess.Game do
  use GenServer

  alias Chess.{Board, Game, Rules}

  defstruct board: Board.starting_position(),
            moves: [],
            black: nil,
            white: nil,
            rules: Rules.new(),
            id: RandomBytes.base62()

  def start_link() do
    game = %Game{}
    GenServer.start_link(__MODULE__, game, name: via_tuple(game.id))
  end

  def add_player(game, user, color) when color in ~w[white black]a do
    GenServer.call(game, {:add_player, user, color})
  end

  def move(game, from, to) do
    case Board.move(game.board, from, to) do
      {:ok, move} ->
        {:ok, %{game | board: move.after_board, moves: [move | game.moves]}}

      {:error, message} ->
        {:error, message}
    end
  end

  def via_tuple(id) do
    {:via, Registry, {Registry.Game, id}}
  end

  def init(game) do
    {:ok, game}
  end

  def handle_call({:add_player, user, color}, _from, state_data) do
    with {:ok, rules} <- Rules.check(state_data.rules, {:add_player, color}) do
      state_data
      |> Map.replace!(color, user)
      |> update_rules(rules)
      |> reply_success(:ok)
    else
      {:error, message} -> {:reply, {:error, message}, state_data}
    end
  end

  defp update_rules(state_data, rules), do: %{state_data | rules: rules}

  defp reply_success(state_data, reply), do: {:reply, reply, state_data}
end
