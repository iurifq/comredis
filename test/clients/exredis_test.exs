defmodule Clients.ExredisTest do
  use ExUnit.Case, async: true
  import Comredis

  setup do
    {:ok, conn} = Exredis.start_link
    {:ok, %{conn: conn}}
  end

  test "works for simple commands", %{conn: conn} do
    Exredis.query(conn, set("Pi", "3.14"))
    assert "3.14" == Exredis.query(conn, get("Pi"))
  end

  test "works for mget and mset", %{conn: conn} do
    Exredis.query conn, mset(~w(key1 value1 key2 value2 key3 value3))
    assert ~w(value1 value2 value3) = Exredis.query conn, mget(~w(key1 key2 key3))
  end

  test "works for pipelines", %{conn: conn} do
    Exredis.query conn, del(:test_list)
    assert ~w(OK 1 2) == Exredis.query_pipe conn, [
      set(:test_el, 1),
      lpush(:test_list, 3),
      lpush(:test_list, 2)
    ]
  end
end
