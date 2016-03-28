defmodule CorrectnessTest do
  use ExUnit.Case, async: false
  use ExCheck
  import Comredis
  alias Comredis.{Command, Command.Argument}

  @commands Comredis.Command.FileReader.load

  # Problematic commands
  # [multi, quit, exec, discard, watch]: breaks the tests as we are running
  # them in a transaction;
  # hstrlen: is available just in the 3.2.0 version of redis;
  # spop: has a new option just available in 3.2.0;
  @blacklist ~w(multi quit exec discard watch hstrlen spop)

  setup do
    {:ok, conn} = Redix.start_link
    Redix.command(conn, multi)
    {:ok, %{conn: conn}}
  end

  for %Command{name: name, canonical_name: canonical_name, arguments: arguments, since: since} <- @commands, !(canonical_name in @blacklist) && since do
    @tag iterations: :math.pow(2, Enum.count(arguments)) |> round

    property :"correct_#{name}_generation", %{conn: conn} do
      for_all c in generate_command(unquote(name)) do
        case Redix.command(conn, c) do
          {:ok, "QUEUED"} -> true
          {:error, %Redix.Error{message: m}} -> {c, m}
        end
      end
    end
  end

  defp generate_command(command_name) do
    command = Enum.find @commands, fn %Command{name: name} -> name == command_name end
    {required, optional} = Enum.reduce command.arguments, {[], []}, fn(argument = %Argument{optional: optional, multiple: multiple, command: command}, {reqs, opts}) ->
      value = generate_argument(argument)
      cond do
        optional || command -> {reqs, opts ++ [{String.to_atom(argument.canonical_command || argument.canonical_name), value}]}
        true -> {reqs ++ [value], opts}
      end
    end

    if optional != [] do
      apply(Comredis, String.to_atom(command.canonical_name), required ++ [optional])
    else
      apply(Comredis, String.to_atom(command.canonical_name), required)
    end
  end

  defp generate_argument(%Argument{type: "integer"}), do: int
  defp generate_argument(%Argument{type: "double"}), do: real
  defp generate_argument(%Argument{type: "key"}), do: oneof([int, list(char)])
  defp generate_argument(%Argument{type: "string"}), do: list(char)
  defp generate_argument(%Argument{type: "pattern"}), do: list(char)
  defp generate_argument(%Argument{type: "posix time"}), do: int
  defp generate_argument(%Argument{type: "enum", enum: list}), do: elements(list)
  defp generate_argument(%Argument{type: [t | type_list]}), do: [generate_argument(%Argument{type: t}) | generate_argument(%Argument{type: type_list})]
  defp generate_argument(%Argument{type: []}), do: []
end