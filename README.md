# Chess

An Elixir chess library that knows about games, moves, boards, and pieces.

## Installation

This library is not yet available [on Hex](https://hex.pm). For now, it can be installed
by adding `chess` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chess, github: "duff/chess"}
  ]
end
```

## Usage

```elixir
iex> alias Chess.Game

iex> game = Game.new()
iex> {:ok, game} = Game.add_player(game, "user_1", :white)
iex> {:ok, game} = Game.add_player(game, "user_2", :black)
iex> {:ok, game} = Game.move(game, "user_1", :e2, :e4)
iex> {:ok, game} = Game.move(game, "user_2", :b7, :b6)
iex> game

#Chess.Game<
  black: "user_2",
  board:
  +--------------------------+
8 |  r  n  b  q  k  b  n  r  |
7 |  p  .  p  p  p  p  p  p  |
6 |  .  p  .  .  .  .  .  .  |
5 |  .  .  .  .  .  .  .  .  |
4 |  .  .  .  .  P  .  .  .  |
3 |  .  .  .  .  .  .  .  .  |
2 |  P  P  P  P  .  P  P  P  |
1 |  R  N  B  Q  K  B  N  R  |
  +--------------------------+
     a  b  c  d  e  f  g  h
,
  id: nil,
  rules: %Chess.Rules{state: :white_turn},
  status: {:in_progress},
  white: "user_1",
  ...
>

iex> Game.move(game, "user_1", :b7, :b6)
{:error, "There is no piece at that position."}

iex> Game.move(game, "user_1", :e4, :b6)
{:error, "That is not a legal move."}
```

