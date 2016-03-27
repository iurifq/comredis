defmodule Comredis.Command.Argument do
  defstruct name: nil, canonical_name: nil, type: nil, optional: false, multiple: false, enum: [], variadic: false, command: nil, canonical_command: nil

  def split_options(arguments) do
    arguments
    |> Enum.partition(fn argument -> !(argument.optional || argument.command) end)
  end
end
