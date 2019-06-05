defmodule Chess.GameTest do
  use ExUnit.Case, async: true

  alias Chess.{Game, Board, Piece, Move, Position, User, Rules}

  describe "start_link" do
    test "board starts out in the right position" do
      {:ok, game} = Game.start_link()
      assert state(game).board == Board.starting_position()
    end

    test "creates a new game with a unique id" do
      {:ok, game1} = Game.start_link()
      {:ok, game2} = Game.start_link()
      assert state(game1).id != nil
      assert state(game1).id != state(game2).id
    end
  end

  describe "add player" do
    test "sets the players and updates the rules" do
      user_1 = User.new()
      user_2 = User.new()

      {:ok, new_state} = handle_call({:add_player, user_1, :black}, %Game{})
      assert new_state.black == user_1
      assert new_state.white == nil

      {:ok, new_state} = handle_call({:add_player, user_2, :white}, new_state)
      assert new_state.black == user_1
      assert new_state.white == user_2
      assert new_state.rules == %Rules{state: :players_set}
    end

    test "fails if the rules aren't followed" do
      {:ok, new_state} = handle_call({:add_player, User.new(), :black}, %Game{})
      {:error, "Unable to take that action."} = handle_call({:add_player, User.new(), :black}, new_state)
    end

    test "fails if the we try to add the same player as both colors - black first" do
      user = User.new()

      {:ok, state} = handle_call({:add_player, user, :black}, %Game{})
      {:error, "The same player cannot play both sides of the board."} = handle_call({:add_player, user, :white}, state)
    end

    test "fails if the we try to add the same player as both colors - white first" do
      user = User.new()

      {:ok, state} = handle_call({:add_player, user, :white}, %Game{})
      {:error, "The same player cannot play both sides of the board."} = handle_call({:add_player, user, :black}, state)
    end
  end

  describe "move succeeds" do
    setup :game_ready_to_move

    test "for white", %{game: game, user_1: user_1} do
      assert :ok == Game.move(game, user_1, :e2, :e4)

      assert %Rules{state: :black_turn} = state(game).rules
      assert {:in_progress} == state(game).status
      assert Board.piece(state(game).board, Position.e4()) == Piece.white_pawn()
      assert Board.piece(state(game).board, Position.e2()) == nil
      assert [%Move{from: %Position{file: :e, rank: 2}, to: %Position{file: :e, rank: 4}}] = state(game).moves
    end

    test "for black", %{game: game, user_1: user_1, user_2: user_2} do
      assert :ok == Game.move(game, user_1, :e2, :e4)
      assert :ok == Game.move(game, user_2, :b7, :b6)

      assert %Rules{state: :white_turn} = state(game).rules
      assert {:in_progress} == state(game).status
      assert Board.piece(state(game).board, Position.b6()) == Piece.black_pawn()
      assert Board.piece(state(game).board, Position.b7()) == nil
      assert [%Move{from: %Position{file: :b, rank: 7}, to: %Position{file: :b, rank: 6}} | _] = state(game).moves
    end
  end

  describe "move fails" do
    setup :game_ready_to_move

    test "if the user isn't playing the game", %{game: game} do
      assert {:error, "Unable to make a move if you're not playing the game."} == Game.move(game, User.new(), :e2, :e4)
    end

    test "if the Board disallows it", %{game: game, user_1: user_1} do
      assert {:error, "That is not a legal move."} == Game.move(game, user_1, :e2, :e8)
    end

    test "if attempting to move your opponent's piece", %{game: game, user_1: user_1} do
      assert {:error, "Unable to move opponent's piece."} == Game.move(game, user_1, :b7, :b6)
    end

    test "if the from or to position aren't legit", %{game: game, user_1: user_1} do
      assert {:error, "Invalid position."} == Game.move(game, user_1, :e9, :e4)
      assert {:error, "Invalid position."} == Game.move(game, user_1, :e2, :z9)
    end
  end

  test "move fails if the rules aren't followed" do
    {:ok, game} = Game.start_link()

    user_1 = User.new()
    assert :ok == Game.add_player(game, user_1, :white)
    assert {:error, "Unable to take that action."} == Game.move(game, user_1, :e2, :e4)
  end

  describe "move causes status change" do
    setup :game_ready_to_move

    test "move puts opponent in check", %{game: game, user_1: user_1, user_2: user_2} do
      :ok = Game.move(game, user_1, :e2, :e4)
      :ok = Game.move(game, user_2, :f7, :f5)
      :ok = Game.move(game, user_1, :d1, :h5)
      assert {:in_check, :black} == state(game).status
      assert %Rules{state: :black_turn} = state(game).rules
    end

    test "move puts opponent in checkmate", %{game: game, user_1: user_1, user_2: user_2} do
      :ok = Game.move(game, user_1, :e2, :e4)
      :ok = Game.move(game, user_2, :h7, :h6)
      :ok = Game.move(game, user_1, :f1, :c4)
      :ok = Game.move(game, user_2, :a7, :a6)
      :ok = Game.move(game, user_1, :d1, :f3)
      :ok = Game.move(game, user_2, :a6, :a5)
      :ok = Game.move(game, user_1, :f3, :f7)
      assert {:in_checkmate, :black} == state(game).status
      assert %Rules{state: :game_over} = state(game).rules
    end
  end

  defp state(game) do
    :sys.get_state(game)
  end

  defp game_ready_to_move(_context) do
    {:ok, game} = Game.start_link()

    user_1 = User.new()
    user_2 = User.new()

    :ok = Game.add_player(game, user_1, :white)
    :ok = Game.add_player(game, user_2, :black)

    [game: game, user_1: user_1, user_2: user_2]
  end

  defp handle_call(params, state) do
    case Game.handle_call(params, nil, state) do
      {:reply, :ok, new_state} -> {:ok, new_state}
      {:reply, {:error, message}, _} -> {:error, message}
    end
  end
end
