defmodule CyptoBankWeb.AccountController do
  use CyptoBankWeb, :controller

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.Account
  alias CyptoBankWeb.Helpers

  action_fallback CyptoBankWeb.FallbackController

  def index(conn, _params) do
    user_id = Helpers.current_user_id(conn)

    accounts = Accounts.list_accounts_for_user(user_id)
    render(conn, "index.json", accounts: accounts)
  end

  def create(conn, _attrs) do
    user_id = Helpers.current_user_id(conn)

    with {:ok, %Account{} = account} <- Accounts.create_account_for_user(user_id) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.account_path(conn, :show, account))
      |> render("show.json", account: account)
    end
  end

  def show(conn, %{"id" => account_id}) do
    user_id = Helpers.current_user_id(conn)

    account = Accounts.get_account_for_user!(user_id, account_id)
    render(conn, "show.json", account: account)
  end
end
