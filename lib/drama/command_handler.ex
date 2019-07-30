defmodule Drama.CommandHandler do
  @moduledoc """
  Defines a Command Handler that receives a command to:
  - ensure that the command data is valid based on the command validations;
  - executes the command using the aggregate;
  """

  # TODO avoid macro!
  defmacro __using__(opts) do
    aggregate = Keyword.get(opts, :aggregate)
    # TODO event_handlers!|| Multiple, ordered list which is cool
    event_handlers = Keyword.get(opts, :event_handlers)

    quote do
      # TODO this name is shit
      import Drama.CommandHandler

      alias Drama.EventStore

      @doc """
      Receives the command struct, validates it and executes it through the aggregate.

      After receiving the new event and aggregate state from the aggregate it attemps to:
      - the event is persisted in the Event Store;
      - the persisted event is broadcasted to the Event Handler;

      Returns an error if:
      - an invalid command is sent;
      - event can't be persisted in the Event Store;
      - event can't be broadcasted to the Event Handler;

      """
      @spec receive(struct) :: :ok | {:error, atom}
      def receive(command) do
        command_module = command.__struct__

        with true <- command_module.valid?(command),
             {:ok, new_event, state} <- unquote(aggregate).execute(command),
             {:ok, persisted_event} <- EventStore.append(new_event),
             :ok <- do_handle(unquote(event_handlers), persisted_event, state) do
          # TODO Acknoledge events
          # TODO Read only not ack events
          # TODO Use a genserve to understand what to recover
          # TODO add snapshotting

          :ok
        else
          false -> {:error, :invalid_command}
          {:error, _reason} = error -> error
        end
      end

      defp do_handle(handlers, persisted_event, state) do
        Enum.map(handlers, fn handler -> handler.handle(persisted_event, state) end)
        |> Enum.uniq()
        |> Enum.all?(&(&1 == :ok))
        |> Kernel.and(:ok)
      end
    end
  end
end
