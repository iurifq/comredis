defmodule ComredisTest do
  use ExUnit.Case, async: true
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
    assert Comredis.hmset("h", ~w(k1 v1 k2 v2)) == ~w(HMSET h k1 v1 k2 v2)
    assert Comredis.hmset("h", [~w(k1 v1), ~w(k2 v2)]) == ~w(HMSET h k1 v1 k2 v2)
  end

  test "command with optional arguments" do
    assert Comredis.bitpos(~s(key), 0, start: 1, endpos: 10) == ["BITPOS", "key", 0, 1, 10]
    assert Comredis.client_kill(ip_port: "ip:port", id: 1) == ["CLIENT KILL", "ip:port", "ID", 1]
    assert Comredis.client_kill(addr: "ip:port", id: 1) == ["CLIENT KILL", "ID", 1, "ADDR", "ip:port"]
    assert Comredis.client_kill(id: 1, addr: "ip:port") == ["CLIENT KILL", "ID", 1, "ADDR", "ip:port"]
  end

  test "complex with optional agument commands" do
    assert Comredis.zrevrangebylex("key", "max", "min", limit: ["offset", "count"]) == ~w(ZREVRANGEBYLEX key max min LIMIT offset count)
    assert Comredis.zrevrangebylex("key", "max", "min") == ~w(ZREVRANGEBYLEX key max min)
  end

  test "commands/0" do
    assert :del in Comredis.commands
    assert :set in Comredis.commands
    assert :zscan in Comredis.commands
  end

  test "command_groups/0" do
    assert :geo in Comredis.command_groups
    assert :hash in Comredis.command_groups
    assert :server in Comredis.command_groups
  end

  test "command_group/1" do
    assert :lpop in Comredis.command_group(:list)
    assert :hmget in Comredis.command_group(:hash)
  end
end
