defmodule Drama.CommandHandlerTest do
  use ExUnit.Case, async: true

  alias Ecto.UUID

  defmodule AddCounter do
    @behaviour Drama.Command

    defstruct [:aggregate_id, :amount, :version]

    @impl true
    def valid?(command) do
      if command.aggregate_id && command.amount && command.version do
        true
      else
        false
      end
    end
  end

  defmodule CounterAdded do
    defstruct [:aggregate_id, :amount, :version]
  end

  defmodule Counter do
    @behaviour Drama.Aggregate

    @impl true
    def execute(%AddCounter{} = command) do
      new_event = %CounterAdded{
        aggregate_id: command.aggregate_id,
        amount: command.amount,
        version: 1
      }

      {:ok, new_event, %{}}
    end

    @impl true
    def apply(_event, state), do: state
  end

  defmodule CounterEventHandler do
    @behaviour Drama.EventHandler

    @impl true
    def handle(_, _) do
      :ok
    end
  end

  defmodule CounterCommandHandler do
    use Drama.CommandHandler, aggregate: Counter, event_handlers: [CounterEventHandler]
  end

  @aggregate_id UUID.generate()

  describe "receive/1" do
    test "returns `:ok` if the command is successfully executed" do
      assert :ok =
               CounterCommandHandler.receive(%AddCounter{
                 aggregate_id: @aggregate_id,
                 amount: 1,
                 version: 1
               })
    end

    test "returns an error and reason if the command is invalid" do
      assert {:error, :invalid_command} =
               CounterCommandHandler.receive(%AddCounter{
                 aggregate_id: @aggregate_id,
                 amount: 1
               })
    end
  end
end
