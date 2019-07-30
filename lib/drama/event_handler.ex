defmodule Drama.EventHandler do
  @moduledoc """
  Defines the API for an Event Handler.
  """

  alias Drama.Event.PersistedEvent

  @doc """
  Listens to a persisted event and an aggregate state.
  You can use the aggregate to apply the persisted event and its state to get a new state,
  and to project new data into the projection store.
  """
  @callback handle(PersistedEvent.t(), map) :: :ok
end
