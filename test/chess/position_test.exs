defmodule Chess.PositionTest do
  use ExUnit.Case

  alias Chess.Position

  test "new" do
    assert {:ok, %Position{file: :d, rank: 3}} = Position.new(:d, 3)
    assert {:ok, %Position{file: :g, rank: 8}} = Position.new(:g, 8)
    assert {:error, "Invalid position"} = Position.new(:g, 0)
    assert {:error, "Invalid position"} = Position.new(:z, 3)
    assert {:error, "Invalid position"} = Position.new(:d, -2)
    assert {:error, "Invalid position"} = Position.new(nil, 3)
    assert {:error, "Invalid position"} = Position.new(:e, nil)
  end

  test "name" do
    assert Position.name(:a, 4) == :a4
    assert Position.name(:e, 7) == :e7
  end

  test "for" do
    assert Position.for(:a5) == %Position{file: :a, rank: 5}
    assert Position.for(:b2) == %Position{file: :b, rank: 2}
  end

  test "valid?" do
    assert !Position.valid?(%Position{file: :b, rank: 0})
    assert !Position.valid?(%Position{file: :b, rank: -2})
    assert !Position.valid?(%Position{file: :b, rank: 9})

    assert Position.valid?(%Position{file: :b, rank: 1})
    assert Position.valid?(%Position{file: :b, rank: 8})
    assert !Position.valid?(%Position{file: nil, rank: 8})
    assert !Position.valid?(%Position{file: "2", rank: 8})

    assert Position.valid?(:d4)
    assert !Position.valid?(:"d-4")
    assert !Position.valid?(:e0)
  end
end
