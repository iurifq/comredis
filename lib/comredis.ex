defmodule Comredis do
  use Comredis.Command.Generator

  @doc """
  Returns the list of all available commands.
  """
  @spec commands() :: list(atom())
  def commands do
    @commands
    |> Enum.map(fn {command, _} -> command end)
  end

  @doc """
  Returns the commands in the command group `group`.
  """
  @spec command_group(atom()) :: list(atom())
  def command_group(group) when is_atom(group) do
    @commands
    |> Enum.filter(fn {_, g} -> group == g end)
    |> Enum.map(fn {command, _} -> command end)
  end

  @doc """
  Return the names of the command groups.
  """
  @spec command_groups() :: list(atom())
  def command_groups do
    @commands
    |> Enum.map(fn {_, group} -> group end)
    |> Enum.uniq
  end
end
