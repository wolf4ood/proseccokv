defmodule Prosecco.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    path = Path.join(System.tmp_dir!(), "prosecco_test")
    File.rm_rf(path)

    {:ok, registry} =
      Prosecco.Registry.start_link(%{
        path: path,
        name: RegistryTest
      })

    %{registry: registry}
  end

  test "spawns kv", %{registry: registry} do
    assert Prosecco.Registry.lookup(registry, "shopping") == :error

    Prosecco.Registry.create(registry, "shopping")

    assert {:ok, ["shopping"]} = Prosecco.Registry.list(registry)

    assert {:ok, bucket} = Prosecco.Registry.lookup(registry, "shopping")

    Prosecco.KV.put(bucket, "milk", "1")

    {:ok, value} = Prosecco.KV.get(bucket, "milk")
    assert "1" == value

    assert Prosecco.Registry.delete(registry, "shopping") == {:ok}

    assert Prosecco.Registry.lookup(registry, "shopping") == :error
  end
end
