defmodule Chess.Move do
  defstruct [:piece, :from, :to, :before_board, :after_board, :captured]
end
