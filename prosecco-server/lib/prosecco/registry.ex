defmodule Prosecco.Registry do
  use GenServer

  @impl true
  def init(opts) do
    {dbs, refs} = find_dbs(opts.path)
    {:ok, %{path: opts.path, dbs: dbs, name: opts.name, refs: refs}}
  end

  defp find_dbs(path) do
    case File.ls(path) do
      {:ok, dbs} ->
        dbs
        |> Enum.map(fn x -> {x, Path.join(path, x)} end)
        |> Enum.filter(fn {_name, path} -> is_sled_storage(path) end)
        |> Enum.map(fn {name, path} ->
          {:ok, db} = Prosecco.KV.start_link(%{path: path})
          ref = Process.monitor(db)
          {name, db, ref}
        end)
        |> Enum.reduce({%{}, %{}}, fn {name, db, ref}, {dbs, refs} ->
          dbs = Map.put(dbs, name, db)
          refs = Map.put(refs, ref, name)
          {dbs, refs}
        end)

      _ ->
        {%{}, %{}}
    end
  end

  defp is_sled_storage(path) do
    File.ls!(path)
    |> Enum.member?("conf")
  end

  def start_link(opts) do
    name = opts.name || __MODULE__
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  def delete(server, name) do
    GenServer.call(server, {:delete, name})
  end

  def list(server) do
    GenServer.call(server, {:list})
  end

  @impl true
  def handle_call({:list}, _from, state) do
    {:reply, {:ok, Map.keys(state.dbs)}, state}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {:reply, Map.fetch(state.dbs, name), state}
  end

  @impl true
  def handle_call({:delete, name}, _from, state) do
    case Map.pop(state.dbs, name) do
      {nil, _dbs} ->
        {:reply, {:error}, state}

      {pop, dbs} ->
        refs = Map.delete(state.refs, pop)
        {:reply, Prosecco.KV.delete(pop), %{path: state.path, dbs: dbs, refs: refs}}
    end
  end

  @impl true
  def handle_call({:create, name}, _from, state) do
    if Map.has_key?(state.dbs, name) do
      {:reply, {:error, msg: "DB with name #{name} exists"}, state}
    else
      {:ok, db} = Prosecco.KV.start_link(%{path: Path.join(state.path, name)})
      ref = Process.monitor(db)
      refs = Map.put(state.refs, ref, name)
      dbs = Map.put(state.dbs, name, db)
      {:reply, {:ok, db}, %{dbs: dbs, path: state.path, refs: refs}}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {name, refs} = Map.pop(state.refs, ref)
    dbs = Map.delete(state.dbs, name)
    {:noreply, %{dbs: dbs, refs: refs, path: state.path}}
  end
end
