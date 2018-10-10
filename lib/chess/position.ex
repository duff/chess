defmodule Chess.Position do
  defstruct [:file, :rank]

  alias Chess.Position

  def name(%Position{rank: rank, file: file}) do
    name(file, rank)
  end

  def name(file, rank) do
    "#{file}#{rank}"
    |> String.to_atom()
  end

  def for(name) do
    {file, rank} = Atom.to_string(name) |> String.split_at(1)
    %Position{file: String.to_atom(file), rank: integer_for(rank)}
  end

  def valid?(name) when is_atom(name) do
    Position.for(name)
    |> valid?()
  end

  def valid?(%Position{file: file, rank: rank}) when rank in 1..8 and file in ~w(a b c d e f g h)a do
    true
  end

  def valid?(_), do: false

  defp integer_for(""), do: 0
  defp integer_for(rank), do: String.to_integer(rank)
end
