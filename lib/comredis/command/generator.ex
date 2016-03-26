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

  def bodies(command) do
    args = command.arguments
            |> Enum.map(&(&1.canonical_command || &1.canonical_name))
            |> Enum.join(", ")

    Code.string_to_quoted!("""
    def #{command.canonical_name}(#{args}) do
      ["#{command.name}" | [#{args}]]
    end
    """)
  end
end
