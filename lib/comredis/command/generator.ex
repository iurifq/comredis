defmodule Comredis.Command.Generator do
  alias Comredis.{Command, Command.Argument, Command.FileReader}

  defmacro __using__(_options) do
    commands = for command <- FileReader.load, do: generate(command)
    quote do
      Module.register_attribute __MODULE__, :commands, accumulate: true
      unquote(commands)
    end
  end

  defp generate(command = %Command{}) do
    quote do
      @commands unquote {
        String.to_atom(command.canonical_name),
        String.to_atom(command.group)
      }
      @doc unquote doc(command)
      unquote bodies(command)
    end
  end

  defp doc(command) do
    basic_doc = """
    #{command.summary}

    *Group:* #{command.group}

    *Available since Redis version #{command.since}.*
    """
    case command.complexity do
      nil -> basic_doc
      complexity -> "#{basic_doc}\n*Time complexity:* #{complexity}"
    end
  end

  defp bodies(command) do
    {required_args, optional_args} = Argument.split_options(command.arguments)
    args = required_args
            |> Enum.map(&(&1.canonical_command || &1.canonical_name))
    {function_parameters, command_parameters} = case optional_args do
      [] -> {args, args}
      _ -> {
        args ++ ["opts \\\\ []"],
        args ++ ["translate_options(~s(#{command.canonical_name}), opts)"]
      }
    end

    quote do
      unquote Code.string_to_quoted!("""
      def #{command.canonical_name}(#{function_parameters |> List.flatten |> Enum.join(", ")}) do
        List.flatten ["#{command.name}" | [#{command_parameters |> List.flatten |> Enum.join(", ")}]]
      end
      """)

      defp translate_options(command_name = unquote(command.canonical_name), opts) do
        arguments = unquote(command.arguments
                    |> Enum.map(fn command -> {String.to_atom(command.canonical_command || command.canonical_name), Map.to_list(command) } end))

        arguments_opts = Enum.group_by(arguments ++ opts, fn {k, _} -> k end)

        translated_options = for {argument_key, list} <- arguments_opts, is_list(list), Enum.count(list) == 2 do
          {argument_key, argument, value} = case list do
            [{argument_key, argument}, {argument_key, value}] when argument |> is_list -> {argument_key, argument, value}
            [{argument_key, value}, {argument_key, argument}] when argument |> is_list -> {argument_key, argument, value}
          end

          case Enum.into(argument, %{}) do
            %{command: command} when is_binary(command) -> { argument_key, [command, value] }
            _ -> { argument_key, [value] }
          end
        end

        Enum.filter_map arguments, fn {key, _} -> List.keymember?(translated_options, key, 0) end, fn {key, _} ->
          {_, value} = List.keyfind(translated_options, key, 0)
          value
        end
      end
    end
  end
end
