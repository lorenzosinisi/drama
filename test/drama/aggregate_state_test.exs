defmodule Drama.AggregateStateTest do
  use ExUnit.Case

  alias Ecto.UUID

  setup do
    on_exit(fn ->
      Application.stop(:drama)
      {:ok, _apps} = Application.ensure_all_started(:drama)
    end)
  end

  defmodule Counter do
    @behaviour Drama.Aggregate

    @impl true
    def execute(_command), do: :ok

    @impl true
    def apply(%{aggregate_id: aggregate_id, event_data: event_data}, %{total: total} = state) do
      %{state | aggregate_id: aggregate_id, total: total + event_data.amount}
    end
  end

  defmodule CounterState do
    use Drama.AggregateState, aggregate: Counter, initial_state: %{aggregate_id: nil, total: 0}
  end

  defmodule CounterAdded do
    defstruct [:aggregate_id, :amount, :version]
  end

  @aggregate_id UUID.generate()

  describe "get/2" do
    test "returns the aggregate initial state when no event happened yet" do
      assert %{aggregate_id: nil, total: 0} = CounterState.get(UUID.generate())
    end

    test "returns the aggregate state after applying all events" do
      event1 = %CounterAdded{aggregate_id: @aggregate_id, amount: 1, version: 1}
      Drama.EventStore.append(event1)
      assert %{aggregate_id: @aggregate_id, total: 1} = CounterState.get(@aggregate_id)

      event2 = %CounterAdded{aggregate_id: @aggregate_id, amount: 3, version: 2}
      Drama.EventStore.append(event2)
      assert %{aggregate_id: @aggregate_id, total: 4} = CounterState.get(@aggregate_id)

      event3 = %CounterAdded{aggregate_id: @aggregate_id, amount: 2, version: 3}
      event4 = %CounterAdded{aggregate_id: @aggregate_id, amount: 10, version: 4}
      Drama.EventStore.append(event3)
      Drama.EventStore.append(event4)
      assert %{aggregate_id: @aggregate_id, total: 16} = CounterState.get(@aggregate_id)
    end
  end
end
