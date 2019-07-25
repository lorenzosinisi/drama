use Mix.Config

config :drama, :event_store, adapter: Drama.EventStore.InMemoryAdapter

config :drama, :projection_store, adapter: Drama.ProjectionStore.InMemoryAdapter
