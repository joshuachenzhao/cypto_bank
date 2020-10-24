defmodule CyptoBankWeb.Helpers do
  import Plug.Conn

  alias CyptoBank.Accounts

  def fetch_current_user_id(conn) do
    conn
    |> get_session(:current_user_id)
    |> case do
      nil -> {:error, :user_id_not_found}
      user_id -> {:ok, user_id}
    end
  end

  def fetch_current_user(conn) do
    with {:ok, user_id} <- fetch_current_user_id(conn) do
      Accounts.fetch_user(user_id)
    end
  end

  def get_current_user_id(conn) do
    conn |> get_session(:current_user_id)
  end

  def get_current_user(conn) do
    conn
    |> get_current_user_id
    |> Accounts.get_user()
  end
end
