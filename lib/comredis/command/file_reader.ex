defmodule Comredis.Command.FileReader do
  alias Comredis.Command
  alias Comredis.Command.Argument

  @command_file "commands.json"

  @derive [Poison.Encoder]

  def load do
    for {name, raw_command} <- from_file do
      command = to_struct(Command, raw_command)
      arguments = for argument <- command.arguments || [] do
        to_struct(Argument, argument)
      end
      Map.merge command, %{
        name: name,
        group: String.to_atom(command.group),
        arguments: arguments,
        function_name: canonize(name) |> String.to_atom,
      }
    end
  end

  defp canonize(nil), do: nil
  defp canonize("end"), do: "endpos"
  defp canonize([h | tail]), do: [canonize(h) | canonize(tail)]
  defp canonize([]), do: []
  defp canonize(name) do
    name |> String.downcase |> String.replace(~r/[ -:]+/, "_")
  end

  defp to_struct(kind, attrs) do
    struct = struct(kind)
    Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} ->
          case bla = Map.fetch!(struct, k) do
            :canonized ->
              %{acc | k => canonize(v) }
            _ ->
              %{acc | k => v}
          end
        :error -> acc
      end
    end
  end

  defp from_file  do
    File.read!(@command_file) |> Poison.decode!
  end
end
