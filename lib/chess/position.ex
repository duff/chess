defmodule Chess.Position do
  defstruct [:x, :y]

  alias Chess.Position

  def name(file, rank) do
    "#{file}#{rank}"
    |> String.to_atom()
  end
end
