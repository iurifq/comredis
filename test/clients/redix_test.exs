defmodule Clients.RedixTest do
  use ExUnit.Case, async: true
  import Comredis

  setup do
    {:ok, conn} = Redix.start_link
    {:ok, %{conn: conn}}
  end

  test "works for simple commands", %{conn: conn} do
    assert {:ok, "PONG"} == Redix.command(conn, ping)

    {:ok, _}                  = Redix.command(conn, set("comredis:set_test", "Comredis"))
    assert {:ok, "Comredis"} == Redix.command(conn, get("comredis:set_test"))
  end

  test "works for pipelines", %{conn: conn} do
    {:ok, _} = Redix.command(conn, set("foo", 0))
    assert {:ok, [1, 2, 4]} == Redix.pipeline conn, [
     incr("foo"),
     incr("foo"),
     incrby("foo", 2)
   ]
  end

  test "works for transactions", %{conn: conn} do
    {:ok, _}        = Redix.command(conn, set("counter", 0))
    {:ok, "OK"}     = Redix.command(conn, multi)
    {:ok, "QUEUED"} = Redix.command(conn, incr("counter"))
    {:ok, "QUEUED"} = Redix.command(conn, incr("counter"))
    {:ok, [1, 2]}   = Redix.command(conn, exec)
  end
end
