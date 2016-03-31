defmodule Comredis.Command.FileReader do
  alias Comredis.Command
  alias Comredis.Command.Argument

  @command_file "commands.json"

  @doc """
  Function that loads the whole command json file

  It reads the file and generates structs of `Command` with their arguments
  as `Argument` structs.
  """
  def load do
    for {name, raw_command} <- from_file do
      command = to_struct(Command, Map.merge(raw_command, %{"name" => String.split(name)}))
      arguments = for argument <- command.arguments || [] do
        argument_struct = to_struct(Argument, argument)
        %{argument_struct | canonical_name: canonize(argument_struct.command) || argument_struct.canonical_name}
      end
      Map.merge command, %{arguments: arguments}
    end
  end

  defp canonize([h | tail]), do: "#{canonize(h)}_#{canonize(tail)}" |> String.strip(?_) |> String.to_atom
  defp canonize(name) when is_binary(name) do
    name |> String.downcase |> String.replace(~r/[ \-:\/]+/, "_") |> String.to_atom
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
