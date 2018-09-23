defmodule Chess.Position do
  defstruct [:file, :rank]

  alias Chess.Position

  def name(file, rank) do
    "#{file}#{rank}"
    |> String.to_atom()
  end

  def for(name) do
    {file, rank} = Atom.to_string(name) |> String.split_at(1)
    %Position{file: String.to_atom(file), rank: String.to_integer(rank)}
  end

  def valid?(name) when is_atom(name) do
    Position.for(name)
    |> valid?()
  end

  def valid?(%Position{rank: rank}) when rank in 1..8 do
    true
  end

  def valid?(_), do: false
end
