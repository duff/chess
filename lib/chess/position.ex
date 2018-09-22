defmodule Chess.Position do
  defstruct [:file, :rank]

  alias Chess.Position

  def name(file, rank) do
    "#{file}#{rank}"
    |> String.to_atom()
  end
end
