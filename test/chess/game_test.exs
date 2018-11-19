defmodule Chess.GameTest do
  use ExUnit.Case

  alias Chess.{Game, Board, Piece, Move, Position, User, Rules}

  setup do
    {:ok, game} = Game.start_link()
    [game: game]
  end

  test "start_link creates a new game with a unique id" do
    {:ok, game1} = Game.start_link()
    {:ok, game2} = Game.start_link()
    assert state(game1).id != nil
    assert state(game1).id != state(game2).id
  end

  test "board starts out in the right position", %{game: game} do
    assert state(game).board == Board.starting_position()
  end

  test "add player sets the players and updates the rules", %{game: game} do
    user_1 = User.new()
    user_2 = User.new()

    assert :ok == Game.add_player(game, user_1, :black)
    assert state(game).black == user_1
    assert state(game).white == nil

    assert :ok == Game.add_player(game, user_2, :white)
    assert state(game).black == user_1
    assert state(game).white == user_2
    assert %Rules{state: :players_set} = state(game).rules
  end

  test "add player fails if the rules aren't followed", %{game: game} do
    assert :ok == Game.add_player(game, User.new(), :black)
    assert {:error, "Unable to take that action."} == Game.add_player(game, User.new(), :black)
  end

  describe "add player fails if the we try to add the same player as both colors" do
    test "black first", %{game: game} do
      user = User.new()
      assert :ok == Game.add_player(game, user, :black)
      assert {:error, "The same player cannot play both sides of the board."} == Game.add_player(game, user, :white)
    end

    test "white first", %{game: game} do
      user = User.new()
      assert :ok == Game.add_player(game, user, :white)
      assert {:error, "The same player cannot play both sides of the board."} == Game.add_player(game, user, :black)
    end
  end

  test "white move successful", %{game: game} do
    user_1 = User.new()
    user_2 = User.new()

    assert :ok == Game.add_player(game, user_1, :white)
    assert :ok == Game.add_player(game, user_2, :black)

    assert :ok == Game.move(game, user_1, :e2, :e4)

    assert %Rules{state: :black_turn} = state(game).rules
    assert Board.piece(state(game).board, Position.e4()) == Piece.white_pawn()
    assert Board.piece(state(game).board, Position.e2()) == nil
    assert [%Move{from: %Position{file: :e, rank: 2}, to: %Position{file: :e, rank: 4}}] = state(game).moves
  end

  test "black move successful", %{game: game} do
    user_1 = User.new()
    user_2 = User.new()

    assert :ok == Game.add_player(game, user_1, :white)
    assert :ok == Game.add_player(game, user_2, :black)

    assert :ok == Game.move(game, user_1, :e2, :e4)
    assert :ok == Game.move(game, user_2, :b7, :b6)

    assert %Rules{state: :white_turn} = state(game).rules
    assert Board.piece(state(game).board, Position.b6()) == Piece.black_pawn()
    assert Board.piece(state(game).board, Position.b7()) == nil
    assert [%Move{from: %Position{file: :b, rank: 7}, to: %Position{file: :b, rank: 6}} | _] = state(game).moves
  end

  test "move fails if the user isn't playing the game", %{game: game} do
    assert {:error, "Unable to make a move if you're not playing the game."} == Game.move(game, User.new(), :e2, :e4)
  end

  test "move fails if the rules aren't followed", %{game: game} do
    user_1 = User.new()

    assert :ok == Game.add_player(game, user_1, :white)
    assert {:error, "Unable to take that action."} == Game.move(game, user_1, :e2, :e4)
  end

  test "move unsuccessful if the Board disallows it", %{game: game} do
    user_1 = User.new()
    user_2 = User.new()

    assert :ok == Game.add_player(game, user_1, :white)
    assert :ok == Game.add_player(game, user_2, :black)

    assert {:error, "That is not a legal move."} == Game.move(game, user_1, :e2, :e8)
  end

  test "move unsuccessful if attempting to move your opponent's piece", %{game: game} do
    user_1 = User.new()
    user_2 = User.new()

    assert :ok == Game.add_player(game, user_1, :white)
    assert :ok == Game.add_player(game, user_2, :black)

    assert {:error, "Unable to move opponent's piece."} == Game.move(game, user_1, :b7, :b6)
  end

  test "move unsuccessful if the from or to position aren't legit", %{game: game} do
    user_1 = User.new()
    user_2 = User.new()

    assert :ok == Game.add_player(game, user_1, :white)
    assert :ok == Game.add_player(game, user_2, :black)

    assert {:error, "Invalid position."} == Game.move(game, user_1, :e9, :e4)
    assert {:error, "Invalid position."} == Game.move(game, user_1, :e2, :z9)
  end

  test "remove duplication in this file" do
    flunk("HMMM")
  end

  defp state(game) do
    :sys.get_state(game)
  end
end
