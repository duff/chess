defmodule Chess.User do
  defstruct [:id, :email, :username]

  alias Chess.User

  def new do
    %User{id: RandomBytes.base62()}
  end
end
