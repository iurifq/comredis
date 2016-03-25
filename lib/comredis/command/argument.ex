defmodule Comredis.Command.Argument do
  defstruct name: :canonized, type: nil, optional: false, multiple: false, enum: [], variadic: false, command: :canonized
end
