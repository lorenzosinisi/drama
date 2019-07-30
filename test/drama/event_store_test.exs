defmodule Drama.EventStoreTest do
  use ExUnit.Case

  alias Ecto.UUID

  alias Drama.Event.PersistedEvent
  alias Drama.EventStore

  setup do
    on_exit(fn ->
      Application.stop(:drama)
      {:ok, _apps} = Application.ensure_all_started(:drama)
    end)
  end

  defmodule CounterAdded do
    defstruct [:aggregate_id, :amount, :version]
  end

  defmodule CounterRemoved do
    defstruct [:aggregate_id, :amount, :version]
  end

  @aggregate_id UUID.generate()

  describe "append/1" do
    test "appends a new event into the event store" do
      event_added = %CounterAdded{aggregate_id: @aggregate_id, amount: 5, version: 1}
      event_removed = %CounterRemoved{aggregate_id: @aggregate_id, amount: 4, version: 2}

      assert {:ok, %PersistedEvent{}} = EventStore.append(event_added)
      assert {:ok, %PersistedEvent{}} = EventStore.append(event_removed)
    end
  end

  describe "get/2" do
    test "returns a list of events for an aggregate id in order" do
      event_added = %CounterAdded{aggregate_id: @aggregate_id, amount: 3, version: 1}
      event_removed = %CounterRemoved{aggregate_id: @aggregate_id, amount: 1, version: 2}
      EventStore.append(event_added)
      EventStore.append(event_removed)

      assert [%PersistedEvent{version: 1}, %PersistedEvent{version: 2}] =
               EventStore.get(@aggregate_id)
    end

    test "returns a list of events for an aggregate id in order, starting from the last unacknoledged event" do
      opts = [start_from: :current]
      aggregate_id = UUID.generate()
      event_added = %CounterAdded{aggregate_id: aggregate_id, amount: 3, version: 1}
      event_removed = %CounterRemoved{aggregate_id: aggregate_id, amount: 1, version: 2}
      {:ok, persisted_event} = EventStore.append(event_added)
      EventStore.append(event_removed)
      EventStore.acknowledge(persisted_event)

      assert [%PersistedEvent{version: 2}] = EventStore.get(aggregate_id, opts)
    end

    test "returns an empty list when no events are found" do
      assert [] = EventStore.get(UUID.generate())
    end
  end
end
