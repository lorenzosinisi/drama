defmodule Drama.EventStore.Adapter do
  @moduledoc """
  Defines the API for an Event Store adapter.
  """

  alias Drama.Event.PersistedEvent

  @doc """
  Receives an aggregate id and returns a list containing all persisted events from the Event Store.
  """
  @callback get(String.t()) :: list

  @doc """
  Appends an event to the Event Store.
  """
  @callback append(map) :: {:ok, PersistedEvent.t()}
end
