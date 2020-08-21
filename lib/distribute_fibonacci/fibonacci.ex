defmodule DistributeFibonacci.Fibonacci do
  def calculate(0) do
    1
  end

  def calculate(1) do
    1
  end

  def calculate(n) when is_integer(n) and n > 1 do
    case :mnesia.dirty_read({Fibonacci, n}) do
      [{_, _, v}] ->
        v

      [] ->
        fn_1 =
          case :mnesia.dirty_read({Fibonacci, n - 1}) do
            [{_, _, v}] ->
              v

            [] ->
              calculate(n - 2) + calculate(n - 3)
          end

        fn_2 =
          case :mnesia.dirty_read({Fibonacci, n - 2}) do
            [{_, _, v}] ->
              v

            [] ->
              calculate(n - 3) + calculate(n - 4)
          end

        fn_1 + fn_2
    end
  end

  def get_mnesia(n) do
    :mnesia.dirty_read({Fibonacci, n})
  end

  def is_calculated(n) do
    case get_mnesia(n) do
      [{_, _, _}] -> true
      [] -> false
    end
  end
end
