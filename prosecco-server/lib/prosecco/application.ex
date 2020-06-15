defmodule Prosecco.Server do
  use Application
  require Logger

  def start(_type, _args) do
    path = Application.get_env(:prosecco, :db_path, Path.join(System.tmp_dir!(), "prosecco"))
    name = registry()

    children = [
      {Plug.Cowboy, scheme: :http, plug: Prosecco.Router, options: [port: 8080]},
      {Prosecco.Supervisor, %{path: path, name: name}}
    ]

    opts = [strategy: :one_for_one, name: Prosecco.Supervisor]

    Logger.info("Starting ProseccoKV 🥂...")

    Supervisor.start_link(children, opts)
  end

  def registry do
    Application.get_env(:prosecco, :registry_name, Prosecco.Registry)
  end
end
