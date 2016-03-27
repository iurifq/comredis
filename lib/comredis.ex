defmodule Comredis do
  @moduledoc """
  Entry point module of the library with all Redis commands functions.

  The functions defined here are loaded in compile time from the
  [Redis commands documentation](https://github.com/antirez/redis-doc/blob/master/commands.json)
  The only exceptions are `commands/0`, `command_group/1` and `command_groups/0`
  that provide a way to look for the desired commands.
  **Because you don't need to remember all of them by heart**
  """
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
  Returns the commands in the given command group.
  """
  @spec command_group(atom()) :: list(atom())
  def command_group(group) when is_atom(group) do
    @commands
    |> Enum.filter(fn {_, g} -> group == g end)
    |> Enum.map(fn {command, _} -> command end)
  end

  @doc """
  Returns the names of the command groups provided by Redis.
  """
  @spec command_groups() :: list(atom())
  def command_groups do
    @commands
    |> Enum.map(fn {_, group} -> group end)
    |> Enum.uniq
  end
end
