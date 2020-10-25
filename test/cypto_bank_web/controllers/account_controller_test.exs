defmodule CyptoBankWeb.AccountControllerTest do
  use CyptoBankWeb.ConnCase

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.Account
  alias CyptoBankWeb.UserControllerTest

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}
  @current_user_attrs %{
    email: "some current user email",
    is_admin: true,
    password: "some current user password"
  }

  def fixture(:current_user) do
    {:ok, current_user} = Accounts.create_user(@current_user_attrs)
    current_user
  end

  def fixture(:account) do
    {:ok, account} = Accounts.create_account_for_user(@current_user, @create_attrs)
    account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: @current_user}
  end

  describe "index" do
    test "lists all accounts for current user", %{conn: conn, current_user: current_user} do
      conn = get(conn, Routes.account_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               # %{
               #   account: %{
               #     balance: account.balance,
               #     id: account.id,
               #     user_id: account.user_id
               #   }
               # }
             ]
    end
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.account_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_account(_) do
    account = fixture(:account)
    %{account: account}
  end
end
