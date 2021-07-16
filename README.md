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
iex> alias Chess.{Game, User}

iex> {:ok, game} = Game.start_link()
{:ok, #PID<0.202.0>}

iex> user_1 = User.new()
%Chess.User{email: nil, id: "sT7JrnAb74AokGBHauZJgw", username: nil}

iex> user_2 = User.new()
%Chess.User{email: nil, id: "yEuWDJecHZ5WfYbcJXhkUw", username: nil}

iex> Game.add_player(game, user_1, :white)
:ok

iex> Game.add_player(game, user_2, :black)
:ok

iex> Game.move(game, user_1, :e2, :e4)
:ok

iex> Game.move(game, user_2, :b7, :b6)
:ok

iex(9)> :sys.get_state(game)

#Chess.Game<
  black: %Chess.User{email: nil, id: "yEuWDJecHZ5WfYbcJXhkUw", username: nil},
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
  id: "9WN13RBp225aTjVjjoFpGA",
  rules: %Chess.Rules{state: :white_turn},
  status: {:in_progress},
  white: %Chess.User{...},
  ...
>

iex> Game.move(game, user_1, :b7, :b6)
{:error, "There is no piece at that position."}

iex> Game.move(game, user_1, :e4, :b6)
{:error, "That is not a legal move."}
```

