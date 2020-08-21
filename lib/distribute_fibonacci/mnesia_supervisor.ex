defmodule DistributeFibonacci.MnesiaSupervisor do
  use Supervisor
  alias :mnesia, as: Mnesia

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opt) do
    if node() == :node1@localhost do
      Mnesia.create_schema([node()])
    end
    Mnesia.start()
    Mnesia.change_config(:extra_db_nodes, [:node1@localhost])
    Mnesia.create_table(Fibonacci, attributes: [:key, :value])
    IO.puts("Mnesia create")

    Supervisor.init([], strategy: :one_for_one)
  end
end
