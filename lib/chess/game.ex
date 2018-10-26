defmodule Chess.Game do
  use GenServer

  alias Chess.{Board, Game, Rules}

  defstruct board: Board.starting_position(), moves: [], rules: Rules.new(), id: RandomBytes.base62()

  def new() do
    %Game{}
  end

  def start_link() do
    game = Game.new()
    GenServer.start_link(__MODULE__, game, name: via_tuple(game.id))
  end

  def move(game, from, to) do
    case Board.move(game.board, from, to) do
      {:ok, move} ->
        {:ok, %{game | board: move.after_board, moves: [move | game.moves]}}

      {:error, message} ->
        {:error, message}
    end
  end

  def init(game) do
    {:ok, game}
  end

  def via_tuple(id) do
    {:via, Registry, {Registry.Game, id}}
  end
end
