defmodule Chess.User do
  defstruct [:email, :username]

  alias Chess.User

  def new do
    %User{}
  end
end
