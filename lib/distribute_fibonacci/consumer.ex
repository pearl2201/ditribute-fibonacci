defmodule DistributeFibonacci.Consumer do
  use GenStage
  @max_demand 1
  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(_opts) do


    {:consumer, :the_state_does_not_matter}
  end

  def subscribe() do
    GenStage.async_subscribe(__MODULE__,
    to: DistributeFibonacci.Producer.via_tuple(),
    cancel: :transient,
    max_demand: @max_demand
  )
  end

  def handle_events(events, _from, state) do

    n = Enum.at(events, 0)
    v = DistributeFibonacci.Fibonacci.calculate(n)

    IO.puts("Fibonnaci: #{n} -> #{v}")

    :mnesia.dirty_write({Fibonacci, n, v})
    Process.sleep(1000)
    # We are a consumer, so we would never emit items.
    {:noreply, [], state}
  end

  def handle_info(message, state) do
    IO.puts("handle info #{inspect(message)}")
    {:noreply, [], state}
  end
end
