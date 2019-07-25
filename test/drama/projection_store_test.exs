defmodule Drama.ProjectionStoreTest do
  use ExUnit.Case

  alias Drama.ProjectionStore

  setup do
    Application.stop(:drama)

    projection_store_config = [
      adapter: Drama.ProjectionStore.InMemoryAdapter,
      options: [
        initial_state: %{counters: []}
      ]
    ]

    Application.put_env(:drama, :projection_store, projection_store_config)
    {:ok, _apps} = Application.ensure_all_started(:drama)

    on_exit(fn ->
      Application.stop(:drama)
      {:ok, _apps} = Application.ensure_all_started(:drama)
    end)
  end

  describe "project/2" do
    test "projects new data into a projection" do
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "123456", amount: 1})
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "123456", amount: 2})
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "123456", amount: 3})
    end
  end

  describe "all/1" do
    test "returns a list of all projections" do
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "123456", amount: 1})
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "789012", amount: 1})
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "789012", amount: 2})
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "123456", amount: 2})
      assert :ok = ProjectionStore.project(:counters, %{aggregate_id: "789012", amount: 3})

      assert [
               %{aggregate_id: "123456", amount: 2},
               %{aggregate_id: "789012", amount: 3}
             ] = ProjectionStore.all(:counters)
    end

    test "returns nil if the projection doesn't exist" do
      refute ProjectionStore.all(:non_existing_projection)
    end
  end
end
