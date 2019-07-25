defmodule Drama.ProjectionStore.InMemoryAdapter do
  @moduledoc """
  Implements an in-memory Projection Store using Agents.
  """

  @behaviour Drama.ProjectionStore.Adapter

  use Agent

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts \\ []) do
    initial_state = Keyword.get(opts, :initial_state, %{})

    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @impl true
  def project(projection_name, %{aggregate_id: aggregate_id} = data) do
    Agent.update(__MODULE__, fn state ->
      update_in(state, [projection_name], fn projections ->
        case Enum.find(projections, &(&1.aggregate_id == aggregate_id)) do
          nil ->
            [data] ++ projections

          _ ->
            Enum.reduce(projections, [], fn record, acc ->
              case record.aggregate_id == aggregate_id do
                true -> [Map.merge(record, data)] ++ acc
                false -> [record] ++ acc
              end
            end)
        end
      end)
    end)
  end

  @impl true
  def all(projection_name) do
    Agent.get(__MODULE__, fn state ->
      Map.get(state, projection_name)
    end)
  end
end
