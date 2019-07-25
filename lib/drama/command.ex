defmodule Drama.Command do
  @moduledoc """
  Defines the API for a Command.
  """
  # TODO is this really what we want? Maybe add different validations? More generic? 
  @doc """
  Returns if a command is valid or not.
  """
  @callback valid?(struct) :: boolean
end
