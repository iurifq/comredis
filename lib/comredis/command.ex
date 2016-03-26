defmodule Comredis.Command do
  defstruct name: nil, canonical_name: nil, summary: nil, complexity: nil, arguments: [], since: nil, group: nil
end
