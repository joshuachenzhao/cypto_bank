defmodule CyptoBankWeb.Helpers do
  @moduledoc """
  Helper module for user/account permission roles handling
  TODO this should moved to a plug
  """
  import Plug.Conn

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.User

  @doc """
  Get signed in user_id from conn session, return tuple
  """
  def fetch_current_user_id(conn) do
    conn
    |> get_session(:current_user_id)
    |> case do
      nil -> {:error, :user_id_not_found}
      user_id -> {:ok, user_id}
    end
  end

  @doc """
  Get signed in user info
  """
  def fetch_current_user(conn) do
    with {:ok, user_id} <- fetch_current_user_id(conn) do
      Accounts.fetch_user(user_id)
    end
  end

  @doc """
  Verify if current signed in user has admin/operation access
  """
  def verify_admin_access(conn) do
    conn |> fetch_current_user() |> admin_check
  end

  @doc """
  Verify if current signed in user owns account of account_id
  """
  def verify_account_access(conn, account_id) do
    with {:ok, user} <- fetch_current_user(conn) do
      Accounts.fetch_account_for_user(user, account_id)
    end
  end

  # Helper for verify_admin_access
  defp admin_check({:ok, %User{is_admin: true} = user}), do: {:ok, user}
  defp admin_check({:ok, %User{}}), do: {:error, :no_admin_access}
  defp admin_check({:error, error}), do: {:error, error}
end
