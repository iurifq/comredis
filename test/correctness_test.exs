defmodule CorrectnessTest do
  use ExUnit.Case, async: true
  use ExCheck
  import Comredis
  alias Comredis.{Command, Command.Argument}

  @commands Comredis.Command.FileReader.load

  # Problematic commands
  # [MULTI, QUIT, EXEC, DISCARD, WATCH]: breaks the tests as we are running
  # them in a transaction;
  # HSTRLEN: is available just in the 3.2.0 version of redis;
  # SPOP: has a new option just available in 3.2.0;
  # cluster commands on travis;
  # MIGRATE and RESTORE have more arguments from 3.0, but Travis runs an older Redis;
  @blacklist (if System.get_env("TRAVIS") do
    ~w(cluster_addslots cluster_count_failure_reports cluster_countkeysinslot cluster_delslots cluster_failover cluster_forget cluster_getkeysinslot cluster_info cluster_keyslot cluster_meet cluster_nodes cluster_replicate cluster_reset cluster_saveconfig cluster_set_config_epoch cluster_setslot cluster_slaves cluster_slots discard exec hstrlen migrate multi quit readonly readwrite restore spop wait watch)a
  else
    ~w(discard exec hstrlen multi quit spop watch)a
  end)

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
    {required, optional} = Enum.reduce command.arguments, {[], []}, fn(argument = %Argument{optional: optional, multiple: _multiple, command: command}, {reqs, opts}) ->
      value = generate_argument(argument)
      if optional || command do
        {reqs, opts ++ [{argument.canonical_name, value}]}
      else
        {reqs ++ [value], opts}
      end
    end

    if optional != [] do
      apply(Comredis, command.canonical_name, required ++ Enum.shuffle [optional])
    else
      apply(Comredis, command.canonical_name, required)
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
