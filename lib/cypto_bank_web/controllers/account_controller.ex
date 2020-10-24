defmodule CyptoBankWeb.AccountController do
  use CyptoBankWeb, :controller
  import CyptoBankWeb.Helpers, only: [fetch_current_user_id: 1]

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.Account

  action_fallback CyptoBankWeb.FallbackController

  def index(conn, _params) do
    with {:ok, user_id} <- fetch_current_user_id(conn) do
      accounts = Accounts.list_accounts_for_user(user_id)
      render(conn, "index.json", accounts: accounts)
    end
  end

  def create(conn, _attrs) do
    with {:ok, user_id} <- fetch_current_user_id(conn),
         {:ok, %Account{} = account} <- Accounts.create_account_for_user(user_id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => account_id}) do
    with {:ok, user_id} <- fetch_current_user_id(conn),
         {:ok, account} <- Accounts.get_account_for_user!(user_id, account_id) do
      render(conn, "show.json", account: account)
    end
  end
end
