import Config

config :prosecco, Prosecco.Server,
  db_path: System.get_env("DB_PATH"),
  registry_name: Prosecco.Registry
