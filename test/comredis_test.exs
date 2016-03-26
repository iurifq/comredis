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

  test "commands with multiple arguments" do
    assert Comredis.brpop("key", 0) == ["BRPOP", "key", 0]
    assert Comredis.brpop(~w(key1 key2), 0) == ["BRPOP", "key1", "key2", 0]
  end
end
