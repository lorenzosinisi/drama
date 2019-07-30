defmodule Drama.AggregateState do
  @moduledoc """
  Defines an Aggregate State macro that receives the aggregate module and an initial state.
  """

  defmacro __using__(opts) do
    aggregate = Keyword.get(opts, :aggregate)
    initial_state = Keyword.get(opts, :initial_state)
    start_from = Keyword.get(opts, :start_from)

    quote do
      import Drama.AggregateState

      alias Drama.EventStore

      @doc """
      Reads all the persisted events for a specific aggregate and apply them, returning the current aggregate state.
      """
      @spec get(String.t()) :: any
      def get(aggregate_id) do
        aggregate_id
        |> EventStore.get(start_from: unquote(start_from))
        |> Enum.reduce(unquote(initial_state), fn event, state ->
          unquote(aggregate).apply(event, state)
        end)
      end
    end
  end
end
