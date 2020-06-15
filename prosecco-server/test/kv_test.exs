defmodule Prosecco.KVTest do
  use ExUnit.Case, async: true

  setup do
    path = Path.join(System.tmp_dir!(), "ProseccoKV")
    File.rm_rf(path)
    {:ok, kv} = Prosecco.KV.start_link(%{path: path})
    %{kv: kv}
  end

  test "insert/get/remove", %{kv: kv} do
    {:ok, _old} = Prosecco.KV.put(kv, "hello", "world")

    {:ok, value} = Prosecco.KV.get(kv, "hello")

    assert "world" == value

    {:ok, removed} = Prosecco.KV.remove(kv, "hello")

    assert "world" == removed

    {:ok, empty} = Prosecco.KV.get(kv, "hello")

    assert nil == empty
  end
end
