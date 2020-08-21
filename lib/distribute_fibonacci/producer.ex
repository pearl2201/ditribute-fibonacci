defmodule DistributeFibonacci.Producer do
  use GenStage
  alias :mnesia, as: Mnesia

  def start_link(initial \\ 0) do
    GenStage.start_link(__MODULE__, initial, name: via_tuple())
  end

  def init(target) do
    IO.puts("Initialize Producer")

    {:producer, %{current: 0, target: 120}}
  end

  def add(n), do: GenServer.cast(via_tuple(), {:add, n})

  def check_state(), do: GenServer.call(via_tuple(),{:check_state})

  def handle_call({:check_state},_from,state) do
    {:reply,state,[],state}
  end

  def handle_cast({:add, n}, _state) do
    {:noreply, [0], %{current: 1, target: n}}
  end

  def handle_demand(_demand, state) do
    if state[:current] <= state[:target] && state[:target] > 0 do
      {:noreply, [state[:current]], %{current: state[:current] + 1, target: state[:target]}}
    else
      {:noreply, [], state}
    end
  end

  def via_tuple(), do: {:via, Horde.Registry, {DistributeFibonacci.AppRegistry, :fibo_producer}}
end
