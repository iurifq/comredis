defmodule Comredis.Command.Generator do
  @moduledoc """
  Module responsible for generating at compile-time a function for each Redis command.
  """

  alias Comredis.{Command, Command.Argument, Command.DocTest, Command.FileReader}

  @doc """
  Macro that defines functions when this module is used.

  A function for each command is defined in the module that executes `use Comredis.Command.Generator`
  """
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
        command.canonical_name,
        String.to_atom(command.group)
      }
      @doc unquote doc(command)
      unquote bodies(command, Argument.split_options(command.arguments))
    end
  end

  defp doc(command) do
    doc_parts = [
      {command.summary, ":placeholder:"},
      {command.group, "*Group:* **:placeholder:**"},
      {command.since, "*Available since version* **:placeholder:**."},
      {command.complexity, "*Time complexity:* :placeholder:"},
      {arguments_doc(command.arguments), "*Arguments:*\n\n:placeholder:"},
      {DocTest.tests(command.canonical_name), "## Examples\n\n:placeholder:"},
    ]
    for {content, doc_part} <- doc_parts, content do
      String.replace(doc_part, ":placeholder:", content)
    end |> Enum.join("\n\n")
  end

  defp arguments_doc([]), do: nil
  defp arguments_doc(arguments) do
    for argument <- arguments do
      [
        "* `#{argument.canonical_name}`",
        [
          argument.optional && "optional",
          argument.multiple && "multiple",
          argument.type && (argument.type != argument.name) && inspect(argument.type) |> String.replace(~w("), ""),
          argument.enum && inspect(argument.enum),
        ] |> Enum.filter(&(&1)) |> Enum.join(", ")
      ] |> Enum.join(" ")
    end |> Enum.join("\n\n")
  end

  defp bodies(command, {required_args, []}) do
    args = argument_names(required_args)
    quote do
      def unquote(command.canonical_name)(unquote_splicing(args)) do
        List.flatten [unquote(command.name), unquote_splicing(args)]
      end
    end
  end

  defp bodies(command, {required_args, optional_args}) do
    args = argument_names(required_args)
    quote do
      def unquote(command.canonical_name)(unquote_splicing(args), opts \\ []) do
        List.flatten [unquote(command.name), unquote_splicing(args) | translate_options(unquote(command.canonical_name), opts)]
      end

      defp translate_options(command_name = unquote(command.canonical_name), opts) do
        arguments = unquote(for argument <- optional_args, do: {argument.canonical_name, Map.to_list(argument) })

        for {canonical_name, argument} <- arguments, value = Keyword.get(opts, canonical_name) do
          case Keyword.fetch(argument, :command) do
            {:ok, command} when is_binary(command) -> [command, value]
            _ -> value
          end
        end
      end
    end
  end

  defp argument_names(arguments) do
    for argument <- arguments, do: { argument.canonical_name, [], Elixir}
  end
end
