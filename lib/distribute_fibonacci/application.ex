defmodule DistributeFibonacci.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: DistributeFibonacci.DynamicSupervisor},
      {Horde.Registry,
       [name: DistributeFibonacci.AppRegistry, keys: :unique, members: registry_members()]},
      {Horde.DynamicSupervisor,
       [
         name: DistributeFibonacci.AppSupervisor,
         strategy: :one_for_one,
         distribution_strategy: Horde.UniformQuorumDistribution,
         max_restarts: 100_000,
         max_seconds: 1,
         members: supervisor_members()
       ]},
      DistributeFibonacci.MnesiaSupervisor,
      %{
        id: HelloWorld.ClusterConnector,
        restart: :transient,
        start:
          {Task, :start_link,
           [
             fn ->
               #Horde.DynamicSupervisor.wait_for_quorum(DistributeFibonacci.AppSupervisor, 30_000)

               Horde.DynamicSupervisor.start_child(
                 DistributeFibonacci.AppSupervisor,
                 DistributeFibonacci.Producer
               )
             end
           ]}
      },

      # Starts a worker by calling: DistributeFibonacci.Worker.start_link(arg)
      # {DistributeFibonacci.Worker, arg}
      DistributeFibonacci.Consumer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: DistributeFibonacci.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp registry_members do
    [
      {DistributeFibonacci.AppRegistry, :node1@localhost},
      {DistributeFibonacci.AppRegistry, :node2@localhost},
      {DistributeFibonacci.AppRegistry, :node3@localhost}
    ]
  end

  defp supervisor_members do
    [
      {DistributeFibonacci.AppSupervisor, :node1@localhost},
      {DistributeFibonacci.AppSupervisor, :node2@localhost},
      {DistributeFibonacci.AppSupervisor, :node3@localhost}
    ]
  end
end
