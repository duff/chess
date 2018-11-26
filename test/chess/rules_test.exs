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

  test "unable to add a white player if the white player has already been added" do
    rules = %Rules{state: :white_added}
    assert {:error, _} = Rules.check(rules, {:add_player, :white})
  end

  test "able to add a black player as the first player" do
    rules = Rules.new()
    assert {:ok, %Rules{state: :black_added}} = Rules.check(rules, {:add_player, :black})
  end

  test "unable to add a black player if the black player has already been added" do
    rules = %Rules{state: :black_added}
    assert {:error, _} = Rules.check(rules, {:add_player, :black})
  end

  test "able to add a black player as the second player" do
    rules = %Rules{state: :white_added}
    assert {:ok, %Rules{state: :players_set}} = Rules.check(rules, {:add_player, :black})
  end

  test "unable to add a black player if both players have already been set" do
    rules = %Rules{state: :players_set}
    assert {:error, _} = Rules.check(rules, {:add_player, :black})
  end

  test "able to add a white player as the second player" do
    rules = %Rules{state: :black_added}
    assert {:ok, %Rules{state: :players_set}} = Rules.check(rules, {:add_player, :white})
  end

  test "unable to add a white player if both players have already been set" do
    rules = %Rules{state: :players_set}
    assert {:error, _} = Rules.check(rules, {:add_player, :white})
  end

  test "white is able to make the first move" do
    rules = %Rules{state: :players_set}
    assert {:ok, %Rules{state: :black_turn}} = Rules.check(rules, {:move, :white})
  end

  test "black is unaable to make the first move" do
    rules = %Rules{state: :players_set}
    assert {:error, _} = Rules.check(rules, {:move, :black})
  end

  test "black is able to make a move" do
    rules = %Rules{state: :black_turn}
    assert {:ok, %Rules{state: :white_turn}} = Rules.check(rules, {:move, :black})
  end

  test "white is unable to make a move if it's black's turn" do
    rules = %Rules{state: :black_turn}
    assert {:error, _} = Rules.check(rules, {:move, :white})
  end

  test "white is able to make a move" do
    rules = %Rules{state: :white_turn}
    assert {:ok, %Rules{state: :black_turn}} = Rules.check(rules, {:move, :white})
  end

  test "black is unable to make a move if it's white's turn" do
    rules = %Rules{state: :white_turn}
    assert {:error, _} = Rules.check(rules, {:move, :black})
  end

  test "endgame_check during white's turn" do
    rules = %Rules{state: :white_turn}

    assert {:ok, ^rules} = Rules.check(rules, {:endgame_check, :white_in_check})
    assert {:ok, ^rules} = Rules.check(rules, {:endgame_check, :in_progress})
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:endgame_check, :black_won})
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:endgame_check, :stalemate})
  end

  test "endgame_check during black's turn" do
    rules = %Rules{state: :black_turn}

    assert {:ok, ^rules} = Rules.check(rules, {:endgame_check, :black_in_check})
    assert {:ok, ^rules} = Rules.check(rules, {:endgame_check, :in_progress})
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:endgame_check, :white_won})
    assert {:ok, %Rules{state: :game_over}} = Rules.check(rules, {:endgame_check, :stalemate})
  end
end
