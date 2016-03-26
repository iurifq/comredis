defmodule ComredisTest do
  use ExUnit.Case
  doctest Comredis

  test "commands without arguments" do
    assert Comredis.quit == ["QUIT"]
    assert Comredis.command == ["COMMAND"]
    assert Comredis.client_list == ["CLIENT LIST"]
  end

  test "comands without optional arguments" do
    assert Comredis.get("key") == ~w(GET key)
    assert Comredis.setnx("key", "value") == ~w(SETNX key value)
    assert Comredis.cluster_count_failure_reports("node-id") == ["CLUSTER COUNT-FAILURE-REPORTS", "node-id"]
  end
end
