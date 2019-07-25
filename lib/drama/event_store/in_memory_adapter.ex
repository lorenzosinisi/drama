defmodule Drama.EventStore.InMemoryAdapter do
  @moduledoc """
  Implements an in-memory Event Store using Agents.
  """

  @behaviour Drama.EventStore.Adapter

  use Agent

  alias Drama.Event.PersistedEvent

  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts \\ []) do
    initial_state = Keyword.get(opts, :initial_state, [])

    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @impl true
  def get(aggregate_id) do
    __MODULE__
    |> Agent.get(& &1)
    |> Enum.filter(&(&1.aggregate_id == aggregate_id))
    |> Enum.reverse()
  end

  @impl true
  def append(event) do
    persisted_event = %PersistedEvent{
      event_id: :rand.uniform(100_000) |> Integer.to_string(),
      aggregate_id: event.aggregate_id,
      event_type: event.__struct__ |> Module.split() |> List.last(),
      version: event.version,
      event_date: DateTime.utc_now(),
      event_data: Map.from_struct(event)
    }

    Agent.update(__MODULE__, &([persisted_event] ++ &1))

    {:ok, persisted_event}
  end
end
