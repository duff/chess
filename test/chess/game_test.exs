defmodule Chess.GameTest do
  use ExUnit.Case, async: true

  alias Chess.{Game, Board, Piece, Move, Position, Rules}

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
      assert game1 != game2
    end

    test "creates a new game with a specified id and reuses the game if the game already exists" do
      {:ok, game1} = Game.start_link("the_id")
      {:ok, game2} = Game.start_link("the_id")
      {:ok, game3} = Game.start_link("another_id")
      assert state(game1).id != nil
      assert state(game1).id == state(game2).id
      assert game1 == game2
      assert game1 != game3
    end
  end

  describe "add player" do
    test "sets the players and updates the rules" do
      {:ok, new_state} = handle_call({:add_player, :user_1, :black}, %Game{})
      assert new_state.black == :user_1
      assert new_state.white == nil

      {:ok, new_state} = handle_call({:add_player, :user_2, :white}, new_state)
      assert new_state.black == :user_1
      assert new_state.white == :user_2
      assert new_state.rules == %Rules{state: :players_set}
    end

    test "fails if the rules aren't followed" do
      {:ok, new_state} = handle_call({:add_player, :username, :black}, %Game{})
      {:error, "Unable to take that action."} = handle_call({:add_player, :another_user, :black}, new_state)
    end

    test "fails if the we try to add the same player as both colors - black first" do
      {:ok, state} = handle_call({:add_player, :username, :black}, %Game{})
      {:error, "The same player cannot play both sides of the board."} = handle_call({:add_player, :username, :white}, state)
    end

    test "fails if the we try to add the same player as both colors - white first" do
      {:ok, state} = handle_call({:add_player, :username, :white}, %Game{})
      {:error, "The same player cannot play both sides of the board."} = handle_call({:add_player, :username, :black}, state)
    end
  end

  describe "move succeeds" do
    setup :game_ready_to_move

    test "for white", %{state: state} do
      {:ok, state} = handle_call({:move, :user_1, :e2, :e4}, state)

      assert state.rules == %Rules{state: :black_turn}
      assert state.status == {:in_progress}
      assert Board.piece(state.board, Position.e4()) == Piece.white_pawn()
      assert Board.piece(state.board, Position.e2()) == nil
      assert [%Move{from: %Position{file: :e, rank: 2}, to: %Position{file: :e, rank: 4}}] = state.moves
    end

    test "for black", %{state: state} do
      {:ok, state} = handle_call({:move, :user_1, :e2, :e4}, state)
      {:ok, state} = handle_call({:move, :user_2, :b7, :b6}, state)

      assert state.rules == %Rules{state: :white_turn}
      assert state.status == {:in_progress}
      assert Board.piece(state.board, Position.b6()) == Piece.black_pawn()
      assert Board.piece(state.board, Position.b7()) == nil
      assert [%Move{from: %Position{file: :b, rank: 7}, to: %Position{file: :b, rank: 6}} | _] = state.moves
    end
  end

  describe "move fails" do
    setup :game_ready_to_move

    test "if the user isn't playing the game", %{state: state} do
      assert {:error, "Unable to make a move if you're not playing the game."} == handle_call({:move, :username, :e2, :e4}, state)
    end

    test "if the Board disallows it", %{state: state} do
      assert {:error, "That is not a legal move."} == handle_call({:move, :user_1, :e2, :e8}, state)
    end

    test "if attempting to move your opponent's piece", %{state: state} do
      assert {:error, "Unable to move opponent's piece."} == handle_call({:move, :user_1, :b7, :b6}, state)
    end

    test "if the from or to position aren't legit", %{state: state} do
      assert {:error, "Invalid position."} == handle_call({:move, :user_1, :e9, :e4}, state)
      assert {:error, "Invalid position."} == handle_call({:move, :user_1, :e2, :z9}, state)
    end

    test "if the rules aren't followed" do
      {:ok, state} = handle_call({:add_player, :user_1, :white}, %Game{})

      assert {:error, "Unable to take that action."} == handle_call({:move, :user_1, :e2, :e4}, state)
    end
  end

  describe "move causes status change" do
    setup :game_ready_to_move

    test "move puts opponent in check", %{state: state} do
      {:ok, state} = handle_call({:move, :user_1, :e2, :e4}, state)
      {:ok, state} = handle_call({:move, :user_2, :f7, :f5}, state)
      {:ok, state} = handle_call({:move, :user_1, :d1, :h5}, state)
      assert state.status == {:in_check, :black}
      assert state.rules == %Rules{state: :black_turn}
    end

    test "move puts opponent in checkmate", %{state: state} do
      {:ok, state} = handle_call({:move, :user_1, :e2, :e4}, state)
      {:ok, state} = handle_call({:move, :user_2, :h7, :h6}, state)
      {:ok, state} = handle_call({:move, :user_1, :f1, :c4}, state)
      {:ok, state} = handle_call({:move, :user_2, :a7, :a6}, state)
      {:ok, state} = handle_call({:move, :user_1, :d1, :f3}, state)
      {:ok, state} = handle_call({:move, :user_2, :a6, :a5}, state)
      {:ok, state} = handle_call({:move, :user_1, :f3, :f7}, state)

      assert state.status == {:in_checkmate, :black}
      assert state.rules == %Rules{state: :game_over}
    end
  end

  defp state(game) do
    :sys.get_state(game)
  end

  defp game_ready_to_move(_context) do
    {:ok, state} = handle_call({:add_player, :user_1, :white}, %Game{})
    {:ok, state} = handle_call({:add_player, :user_2, :black}, state)

    [state: state]
  end

  defp handle_call(params, state) do
    case Game.handle_call(params, nil, state) do
      {:reply, :ok, new_state} -> {:ok, new_state}
      {:reply, {:error, message}, _} -> {:error, message}
    end
  end
end
