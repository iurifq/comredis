defmodule Comredis.Command.Argument do
  defstruct name: nil, canonical_name: nil, type: nil, optional: false, multiple: false, enum: [], variadic: false, command: nil, canonical_command: nil
end
