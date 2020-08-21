defmodule DistributeFibonacci.StartupSupervisor do
  use Horde.DynamicSupervisor

  def start_link(init_arg, options \\ []) do
    Horde.DynamicSupervisor.start_link(__MODULE__, init_arg, options)
  end

  def init(init_arg) do
    [strategy: :one_for_one, members: members()]
    |> Keyword.merge(init_arg)
    |> Horde.DynamicSupervisor.init()
  end

  defp members() do
    [DistributeFibonacci.Producer]
  end
end
