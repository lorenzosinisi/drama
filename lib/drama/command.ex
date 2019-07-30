defmodule Drama.Command do
  @moduledoc """
  Defines the API for a Command.
  """
  @doc """
  Return the command if it command is valid or an error if it is not.
  """
  @callback valid?(struct) :: struct | {:error, any()}
end
