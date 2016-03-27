defmodule Comredis.Command.DocTest do
  @moduledoc """
  Module that contains every doctest for commands. They will be included
  both in the tests and in the documentation for each command function.
  """

  @doc """
  Function that returns the doctests for the command described with the given
  `canonical_command_name`.

  Each command can define a body of this function. By convention, the argument must
  must be the canonical name of the command.

  When no doctest is found, it returns `nil`.
  """
  def tests(canonical_command_name)
  def tests("client_list") do
    """
        iex> Comredis.client_list
        ["CLIENT", "LIST"]
    """
  end

  def tests("client_pause") do
    """
        iex> Comredis.client_pause(1000)
        ["CLIENT", "PAUSE", 1000]
    """
  end

  def tests("command") do
    """
        iex> Comredis.command
        ["COMMAND"]
    """
  end

  def tests("quit") do
    """
        iex> Comredis.quit
        ["QUIT"]
    """
  end
  def tests(_), do: nil
end
