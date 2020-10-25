defmodule CyptoBankWeb.Helpers do
  import Plug.Conn

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.User

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

  def admin_check({:ok, %User{is_admin: true} = user}), do: {:ok, user}
  def admin_check({:ok, %User{}}), do: {:error, :no_admin_access}
  def admin_check({:error, error}), do: {:error, error}

  def account_ownership_check(conn, account_id) do
    with {:ok, user} <- fetch_current_user(conn) do
      Accounts.fetch_account_for_user(user, account_id)
    end
  end
end
