defmodule Comredis.Command.FileReader do
  alias Comredis.Command
  alias Comredis.Command.Argument

  @command_file "commands.json"

  @derive [Poison.Encoder]

  def load do
    for {name, raw_command} <- from_file do
      command = to_struct(Command, Map.merge(raw_command, %{"name" => name}))
      arguments = for argument <- command.arguments || [] do
        to_struct(Argument, argument)
      end
      Map.merge command, %{arguments: arguments}
    end
  end

  defp canonize("end"), do: "endpos"
  defp canonize([h | tail]), do: "#{canonize(h)}_#{canonize(tail)}" |> String.strip(?_)
  defp canonize(name) when is_binary(name) do
    name |> String.downcase |> String.replace(~r/[ -:]+/, "_")
  end
  defp canonize(other), do: other

  defp to_struct(kind, attrs) do
    struct = struct(kind)
    Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} ->
          case { Map.fetch(struct, k), Map.fetch(struct, canonical = :"canonical_#{k}") } do
            {_, {:ok, _}} -> %{acc | k => v, canonical => canonize(v) }
            {{:ok, _}, _}-> %{acc | k => v}
            _ -> acc
          end
        :error -> acc
      end
    end
  end

  defp from_file  do
    File.read!(@command_file) |> Poison.decode!
  end
end
