defmodule Chess.PositionTest do
  use ExUnit.Case, async: true

  alias Chess.Position

  test "new" do
    assert {:ok, %Position{file: :d, rank: 3}} = Position.new(:d, 3)
    assert {:ok, %Position{file: :g, rank: 8}} = Position.new(:g, 8)
    assert {:error, "Invalid position."} = Position.new(:g, 0)
    assert {:error, "Invalid position."} = Position.new(:z, 3)
    assert {:error, "Invalid position."} = Position.new(:d, -2)
    assert {:error, "Invalid position."} = Position.new(nil, 3)
    assert {:error, "Invalid position."} = Position.new(:e, nil)
  end

  test "new based on name string" do
    assert {:ok, %Position{file: :d, rank: 3}} = Position.new("d3")
    assert {:ok, %Position{file: :b, rank: 1}} = Position.new("b1")
    assert {:error, "Invalid position."} = Position.new("z4")
    assert {:error, "Invalid position."} = Position.new("something_odd")
    assert {:error, "Invalid position."} = Position.new("")
  end

  test "new based on name atom" do
    assert {:ok, %Position{file: :d, rank: 3}} = Position.new(:d3)
    assert {:ok, %Position{file: :b, rank: 1}} = Position.new(:b1)
    assert {:error, "Invalid position."} = Position.new(:z4)
    assert {:error, "Invalid position."} = Position.new(:something_odd)
    assert {:error, "Invalid position."} = Position.new(:"")
  end

  test "new based on nil" do
    assert {:error, "Invalid position."} = Position.new(nil)
  end

  test "function shortcuts" do
    assert Position.d4() == %Position{file: :d, rank: 4}
    assert Position.d5() == %Position{file: :d, rank: 5}
    assert Position.g1() == %Position{file: :g, rank: 1}
  end

  test "for" do
    assert Position.for(:a5) == %Position{file: :a, rank: 5}
    assert Position.for(:b2) == %Position{file: :b, rank: 2}

    assert_raise MatchError, fn ->
      Position.for(:z3)
    end
  end
end
