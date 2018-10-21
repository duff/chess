defmodule Chess.Position do
  defstruct [:file, :rank]

  alias Chess.Position

  @valid_ranks 1..8
  @valid_files ~w(a b c d e f g h)a

  def new(file, rank) when rank in @valid_ranks and file in @valid_files do
    {:ok, %Position{file: file, rank: rank}}
  end

  def new(_file, _rank) do
    {:error, "Invalid position"}
  end

  for rank <- @valid_ranks,
      file <- @valid_files do
    def unquote(:"#{file}#{rank}")() do
      {:ok, position} = Position.new(unquote(file), unquote(rank))
      position
    end
  end

  def name(%Position{rank: rank, file: file}) do
    name(file, rank)
  end

  # Remove
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
