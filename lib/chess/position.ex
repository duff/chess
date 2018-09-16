defmodule Chess.Position do
  defstruct [:x, :y]

  alias Chess.Position

  def a1, do: %Position{x: 1, y: 1}
  def b1, do: %Position{x: 2, y: 1}
  def c1, do: %Position{x: 3, y: 1}
  def d1, do: %Position{x: 4, y: 1}
  def e1, do: %Position{x: 5, y: 1}
  def h8, do: %Position{x: 8, y: 8}

  def name(1, 1), do: :a1
  def name(2, 1), do: :b1
  def name(3, 1), do: :c1
  def name(8, 8), do: :h8

  def position_at(name) do
    apply(Position, name, [])
  end
end
