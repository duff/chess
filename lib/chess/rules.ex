defmodule Chess.Rules do
  alias Chess.Rules

  defstruct state: :initialized

  def new do
    %Rules{}
  end

  def check(%Rules{state: :initialized} = rules, {:add_player, :white}) do
    {:ok, %Rules{rules | state: :white_added}}
  end

  def check(%Rules{state: :initialized} = rules, {:add_player, :black}) do
    {:ok, %Rules{rules | state: :black_added}}
  end

  def check(%Rules{state: :white_added} = rules, {:add_player, :black}) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :black_added} = rules, {:add_player, :white}) do
    {:ok, %Rules{rules | state: :players_set}}
  end

  def check(%Rules{state: :players_set} = rules, {:move, :white}) do
    {:ok, %Rules{rules | state: :black_turn}}
  end

  def check(%Rules{state: :black_turn} = rules, {:move, :black}) do
    {:ok, %Rules{rules | state: :white_turn}}
  end

  def check(%Rules{state: :white_turn} = rules, {:move, :white}) do
    {:ok, %Rules{rules | state: :black_turn}}
  end

  def check(%Rules{state: state} = rules, {:endgame_check, status}) when state in ~w[white_turn black_turn]a do
    case status do
      {:in_check, _} -> {:ok, rules}
      {:in_progress} -> {:ok, rules}
      {:in_checkmate, _} -> {:ok, %Rules{rules | state: :game_over}}
      {:stalemate, _} -> {:ok, %Rules{rules | state: :game_over}}
    end
  end

  def check(_state, _action), do: {:error, "Unable to take that action."}
end
