defmodule Chess.GameTest do
  use ExUnit.Case, async: true

  alias Chess.{Game, Board, Piece, Move, Position, Rules}

  describe "add player" do
    test "sets the players and updates the rules" do
      {:ok, game} = Game.add_player(Game.new(), :user_1, :black)
      assert game.black == :user_1
      assert game.white == nil

      {:ok, game} = Game.add_player(game, :user_2, :white)
      assert game.black == :user_1
      assert game.white == :user_2
      assert game.rules == %Rules{state: :players_set}
    end

    test "fails if the rules aren't followed" do
      {:ok, game} = Game.add_player(Game.new(), :username, :black)
      {:error, "Unable to take that action."} = Game.add_player(game, :another_user, :black)
    end

    test "fails if the we try to add the same player as both colors - black first" do
      {:ok, game} = Game.add_player(Game.new(), :username, :black)
      {:error, "The same player cannot play both sides of the board."} = Game.add_player(game, :username, :white)
    end

    test "fails if the we try to add the same player as both colors - white first" do
      {:ok, game} = Game.add_player(Game.new(), :username, :white)
      {:error, "The same player cannot play both sides of the board."} = Game.add_player(game, :username, :black)
    end
  end

  describe "move succeeds" do
    setup :game_ready_to_move

    test "for white", %{game: game} do
      {:ok, game} = Game.move(game, :user_1, :e2, :e4)

      assert game.rules == %Rules{state: :black_turn}
      assert game.status == {:in_progress}
      assert Board.piece(game.board, Position.e4()) == Piece.white_pawn()
      assert Board.piece(game.board, Position.e2()) == nil
      assert [%Move{from: %Position{file: :e, rank: 2}, to: %Position{file: :e, rank: 4}}] = game.moves
    end

    test "for black", %{game: game} do
      {:ok, game} = Game.move(game, :user_1, :e2, :e4)
      {:ok, game} = Game.move(game, :user_2, :b7, :b6)

      assert game.rules == %Rules{state: :white_turn}
      assert game.status == {:in_progress}
      assert Board.piece(game.board, Position.b6()) == Piece.black_pawn()
      assert Board.piece(game.board, Position.b7()) == nil
      assert [%Move{from: %Position{file: :b, rank: 7}, to: %Position{file: :b, rank: 6}} | _] = game.moves
    end
  end

  describe "move fails" do
    setup :game_ready_to_move

    test "if the user isn't playing the game", %{game: game} do
      assert {:error, "Unable to make a move if you're not playing the game."} == Game.move(game, :username, :e2, :e4)
    end

    test "if the Board disallows it", %{game: game} do
      assert {:error, "That is not a legal move."} == Game.move(game, :user_1, :e2, :e8)
    end

    test "if attempting to move your opponent's piece", %{game: game} do
      assert {:error, "Unable to move opponent's piece."} == Game.move(game, :user_1, :b7, :b6)
    end

    test "if the from or to position aren't legit", %{game: game} do
      assert {:error, "Invalid position."} == Game.move(game, :user_1, :e9, :e4)
      assert {:error, "Invalid position."} == Game.move(game, :user_1, :e2, :z9)
    end

    test "if the rules aren't followed" do
      {:ok, game} = Game.add_player(Game.new(), :user_1, :white)

      assert {:error, "Unable to take that action."} == Game.move(game, :user_1, :e2, :e4)
    end
  end

  describe "move causes status change" do
    setup :game_ready_to_move

    test "move puts opponent in check", %{game: game} do
      {:ok, game} = Game.move(game, :user_1, :e2, :e4)
      {:ok, game} = Game.move(game, :user_2, :f7, :f5)
      {:ok, game} = Game.move(game, :user_1, :d1, :h5)
      assert game.status == {:in_check, :black}
      assert game.rules == %Rules{state: :black_turn}
    end

    test "move puts opponent in checkmate", %{game: game} do
      {:ok, game} = Game.move(game, :user_1, :e2, :e4)
      {:ok, game} = Game.move(game, :user_2, :h7, :h6)
      {:ok, game} = Game.move(game, :user_1, :f1, :c4)
      {:ok, game} = Game.move(game, :user_2, :a7, :a6)
      {:ok, game} = Game.move(game, :user_1, :d1, :f3)
      {:ok, game} = Game.move(game, :user_2, :a6, :a5)
      {:ok, game} = Game.move(game, :user_1, :f3, :f7)

      assert game.status == {:in_checkmate, :black}
      assert game.rules == %Rules{state: :game_over}
    end
  end

  defp game_ready_to_move(_context) do
    {:ok, game} = Game.add_player(Game.new(), :user_1, :white)
    {:ok, game} = Game.add_player(game, :user_2, :black)

    [game: game]
  end
end
