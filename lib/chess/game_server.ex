defmodule Chess.GameServer do
  use GenServer

  alias Chess.Game

  def start_link() do
    start_genserver(RandomBytes.base62())
  end

  def start_link(game_id) do
    case GenServer.whereis(via_tuple(game_id)) do
      nil -> start_genserver(game_id)
      existing -> {:ok, existing}
    end
  end

  def add_player(game_server, username, color) do
    GenServer.call(game_server, {:add_player, username, color})
  end

  def move(game_server, username, from, to) do
    GenServer.call(game_server, {:move, username, from, to})
  end

  def via_tuple(id) do
    {:via, Registry, {Registry.Game, id}}
  end

  defp start_genserver(id) do
    GenServer.start_link(__MODULE__, %Game{id: id}, name: via_tuple(id))
  end

  defp reply_success(game), do: {:reply, :ok, game}
  defp reply_error(game, message), do: {:reply, {:error, message}, game}

  def init(game) do
    {:ok, game}
  end

  def handle_call({:add_player, username, color}, _from, game) when color in ~w[white black]a do
    case Game.add_player(game, username, color) do
      {:ok, game} -> reply_success(game)
      {:error, message} -> reply_error(game, message)
    end
  end

  def handle_call({:move, username, from, to}, _from, game) do
    case Game.move(game, username, from, to) do
      {:ok, game} -> reply_success(game)
      {:error, message} -> reply_error(game, message)
    end
  end
end
