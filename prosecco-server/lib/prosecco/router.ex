defmodule Prosecco.Router do
  use Plug.Router

  plug(Corsica, origins: "http://localhost:3000", allow_headers: :all)

  plug(Plug.Logger)

  plug(:match)

  plug(Plug.Parsers, parsers: [:json], json_decoder: Jason)

  plug(:dispatch)

  get "/" do
    {:ok, json} = Jason.encode(%{message: "Welcome to ProseccoKV"})
    send_resp(conn, 200, json)
  end

  get "/databases" do
    {status, body} =
      case Prosecco.Registry.list(registry()) do
        {:ok, dbs} ->
          {200, Jason.encode!(%{databases: dbs})}

        _ ->
          {422, Jason.encode!(%{message: "Missing database name"})}
      end

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  post "/databases" do
    {status, body} =
      with %{"name" => name} <- conn.body_params,
           {:ok, _db} <- Prosecco.Registry.create(registry(), name) do
        {200, Jason.encode!(%{message: "Database created"})}
      else
        {:error, response} ->
          {422, Jason.encode!(%{message: response[:msg]})}

        _ ->
          {422, Jason.encode!(%{message: "Missing database name"})}
      end

    send_resp(conn, status, body)
  end

  put "/databases/:db_name/:key" do
    with {:ok, db} <- Prosecco.Registry.lookup(registry(), db_name),
         {:ok, prev} <- Prosecco.KV.put(db, key, Jason.encode!(conn.body_params)) do
      {:ok, encoded} =
        case prev do
          nil -> {:ok, nil}
          _ -> Jason.decode(prev)
        end

      send_resp(conn, 200, Jason.encode!(%{oldValue: encoded}))
    else
      :error ->
        not_found(conn)
    end
  end

  get "/databases/:db_name/:key" do
    with {:ok, db} <- Prosecco.Registry.lookup(registry(), db_name),
         {:ok, value} <- Prosecco.KV.get(db, key) do
      case value do
        nil -> not_found(conn)
        _ -> send_resp(conn, 200, value)
      end
    else
      :error ->
        not_found(conn)
    end
  end

  delete "/databases/:db_name/:key" do
    with {:ok, db} <- Prosecco.Registry.lookup(registry(), db_name),
         {:ok, value} <- Prosecco.KV.remove(db, key) do
      case value do
        nil -> not_found(conn)
        _ -> send_resp(conn, 200, value)
      end
    else
      :error ->
        not_found(conn)
    end
  end

  delete "/databases/:db_name" do
    case Prosecco.Registry.delete(registry(), db_name) do
      {:ok} -> send_resp(conn, 204, "")
      {:error} -> not_found(conn)
    end
  end

  match _ do
    not_found(conn)
  end

  defp not_found(conn) do
    {:ok, json} = Jason.encode(%{message: "Not found"})
    send_resp(conn, 404, json)
  end

  defp registry() do
    Process.whereis(Prosecco.Server.registry())
  end
end
