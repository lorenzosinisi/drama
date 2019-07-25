# Drama 

Event Sourcing and CQRS in Elixir abstractions.

## Goals

* incentivize the usage of **Event Sourcing** and **CQRS** as good choice for domains that can leverage the main benefits of this design pattern;
* serve as guidance when using Event Sourcing in your system;
* leverage functions and reducers for executing commands and applying events;
* allow customization for fine-grained needs without compromising the principles;
* events acknoledgment
* minimum GenServer implementation to leverage concurrency and OTP

## Event Sourcing and CQRS

In a nutshell, Event Sourcing ensures that all changes to application state are stored as a sequence of events. But if you are new to **Event Sourcing** and **CQRS** I highly recommend watch [Greg Young's presentation at Code on the Beach 2014](https://www.youtube.com/watch?v=JHGkaShoyNs) before moving forward.

## Main Components

* **Command** is a data structure with basic validation;
* **Command Handler** is the entry point of a command in the write side, it performs basic command validation and executes the command through the aggregate;
* **Aggegate Server** is the entry point of a new event that turns into a command in the write side
* **Aggregate** only defines its business logic to execute a command and apply an event, but not its state;
* **Aggregate State** is defined by playing all the events through Aggregate business logic;
* **Event** is a data structure;
* **Event Handler** receives a persisted event and performs the actions in the read side;
* **Event Store** and **Projection Store** are swappable persistence layers to allow different technologies over time;
* **Projection** can be rebuilt based on the persisted events and on the same Aggregate business logic;

## Roadmap

### Next Steps
- [ ] add Postgres as an option for event and projection storage via a built-in Ecto Adapter;
- [ ] DO THE TODOS
- [ ] Write a lot of documentation

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `incident` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:drama, "~> 0.2.0"}
  ]
end
```

## Configuration

### Event Store and Projection Store Setup

Configure `incident` **Event Store** and **Projection Store** adapters and if desired, some options. The options will be passed in during the adapter initialization.

```elixir
config :drama, :event_store, adapter: Drama.EventStore.InMemoryAdapter,
  options: [
    initial_state: []
]

config :drama, :projection_store, adapter: Drama.ProjectionStore.InMemoryAdapter,
  options: [
    initial_state: %{}
]
```


## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/incident](https://hexdocs.pm/drama).

