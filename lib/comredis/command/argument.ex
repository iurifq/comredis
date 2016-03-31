defmodule Comredis.Command.Argument do
  @doc """
  The Argument struct.

  It will encompass all data read from the command file for each argument.

  * `:name` - name of the argument as read from the file
  * `:canonical_name` - string representation of the name
  * `:type` - type of the argument
  * `:optional` - boolean value indicating if the argument is optional
  * `:multiple` - boolean value indicating if the argument can be used multiple times
  * `:enum` - possible values if the argument is enumerable
  * `:variadic` -
  * `:command` - command that must preceed the argument
  """
  defstruct name: nil, canonical_name: nil, type: nil, optional: false, multiple: false, enum: nil, variadic: false, command: nil

  @doc """
  Function to split the arguments that are optional or commands from the required ones.

  It will receive a list of `Comredis.Command.Argument` structs and return a tuple
  with the required arguments first and then the others.
  """
  def split_options(arguments) do
    arguments
    |> Enum.partition(fn argument -> !(argument.optional || argument.command) end)
  end
end
