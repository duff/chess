defmodule Chess.Position do
  defstruct [:file, :rank]

  alias Chess.Position

  @ranks 1..8
  @files ~w(a b c d e f g h)a

  def new(file, rank) when rank in @ranks and file in @files do
    {:ok, %Position{file: file, rank: rank}}
  end

  def new(_file, _rank) do
    {:error, "Invalid position."}
  end

  def new(position_name) when is_atom(position_name) do
    position_name
    |> Atom.to_string()
    |> new()
  end

  def new(position_name) when is_binary(position_name) do
    {file, rank} = position_name |> String.split_at(1)
    Position.new(String.to_atom(file), integer_for(rank))
  end

  def new(_position_name) do
    {:error, "Invalid position."}
  end

  for rank <- @ranks,
      file <- @files do
    def unquote(:"#{file}#{rank}")() do
      {:ok, position} = Position.new(unquote(file), unquote(rank))
      position
    end
  end

  def name(%Position{rank: rank, file: file}) do
    "#{file}#{rank}"
    |> String.to_atom()
  end

  def for(name) do
    {:ok, position} = new(name)
    position
  end

  def files, do: @files
  def ranks, do: @ranks

  defp integer_for(rank) do
    case Integer.parse(rank) do
      {value, ""} -> value
      _ -> 0
    end
  end
end
