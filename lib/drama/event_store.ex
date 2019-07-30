defmodule Drama.EventStore do
  @moduledoc """
  Defines the API to interact with the Event Store.

  The data source is based on the configured Event Store Adapter.
  """
  # TODO bad naming, change
  @doc false
  def get(aggregate_id) do
    apply(adapter(), :get, [aggregate_id])
  end

  # TODO check this naming, append what where? 
  @doc false
  def append(event) do
    apply(adapter(), :append, [event])
  end

  # TODO fail is this does not exists
  @spec adapter :: module
  defp adapter do
    Application.get_env(:drama, :event_store)[:adapter]
  end
end
