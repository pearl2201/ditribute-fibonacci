defmodule DistributeFibonacciTest do
  use ExUnit.Case
  doctest DistributeFibonacci

  test "greets the world" do
    assert DistributeFibonacci.hello() == :world
  end
end
