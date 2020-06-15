defmodule Prosecco.KV do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl true
  def init(opts) do
    db = Sled.open(opts.path)
    {:ok, %{path: opts.path, db: db}}
  end

  def put(db, key, value) do
    GenServer.call(db, {:put, key, value})
  end

  def get(db, key) do
    GenServer.call(db, {:get, key})
  end

  def remove(db, key) do
    GenServer.call(db, {:remove, key})
  end

  def delete(db) do
    GenServer.call(db, {:delete})
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    old = Sled.insert(state.db, key, value)
    {:reply, {:ok, old}, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    value = Sled.get(state.db, key)
    {:reply, {:ok, value}, state}
  end

  @impl true
  def handle_call({:delete}, _from, state) do
    File.rm_rf(state.path)
    {:reply, {:ok}, %{}}
  end

  @impl true
  def handle_call({:remove, key}, _from, state) do
    value = Sled.remove(state.db, key)
    {:reply, {:ok, value}, state}
  end
end
