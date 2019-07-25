defmodule Drama.ProjectionStore do
  @moduledoc """
  Defines the API to interact with the Projection Store.

  The data source is based on the configured Projection Store Adapter.
  """
  # TODO check the naming and strategy here
  @doc false
  def project(projection_name, data) do
    apply(adapter(), :project, [projection_name, data])
  end

  # TODO bad name
  @doc false
  def all(projection_name) do
    apply(adapter(), :all, [projection_name])
  end

  # TODO fail is this does not exists
  @spec adapter :: module
  defp adapter do
    Application.get_env(:incident, :projection_store)[:adapter]
  end
end
