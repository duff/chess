defmodule Chess.RulesTest do
  use ExUnit.Case

  alias Chess.Rules

  test "defaults to initialized" do
    assert Rules.new().state == :initialized
  end

  test "able to add a white player as the first player" do
    rules = Rules.new()
    assert {:ok, %Rules{state: :white_added}} = Rules.check(rules, {:add_player, :white})
  end

  test "able to add a black player as the first player" do
    rules = Rules.new()
    assert {:ok, %Rules{state: :black_added}} = Rules.check(rules, {:add_player, :black})
  end

  test "able to add a black player as the second player" do
    rules = %Rules{state: :white_added}
    assert {:ok, %Rules{state: :players_set}} = Rules.check(rules, {:add_player, :black})
  end

  test "able to add a white player as the second player" do
    rules = %Rules{state: :black_added}
    assert {:ok, %Rules{state: :players_set}} = Rules.check(rules, {:add_player, :white})
  end

  test "white is able to make the first move" do
    rules = %Rules{state: :players_set}
    assert {:ok, %Rules{state: :black_turn}} = Rules.check(rules, {:move, :white})
  end

  test "black is able to make a move" do
    rules = %Rules{state: :black_turn}
    assert {:ok, %Rules{state: :white_turn}} = Rules.check(rules, {:move, :black})
  end

  test "white is able to make a move" do
    rules = %Rules{state: :white_turn}
    assert {:ok, %Rules{state: :black_turn}} = Rules.check(rules, {:move, :white})
  end

  test "win check during white's turn" do
    rules = %Rules{state: :white_turn}
    assert {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:win_check, :win})
  end

  test "win check during black's turn" do
    rules = %Rules{state: :black_turn}
    assert {:ok, rules} = Rules.check(rules, {:win_check, :no_win})
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:win_check, :win})
  end
end
