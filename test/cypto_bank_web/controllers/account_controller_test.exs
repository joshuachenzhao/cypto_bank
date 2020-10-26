defmodule CyptoBankWeb.AccountControllerTest do
  use CyptoBankWeb.ConnCase

  import CyptoBank.Factory

  alias CyptoBank.Accounts

  @invalid_attrs %{}
  @create_attrs %{}
  @current_user_attrs %{
    email: "current_user@email.com",
    is_admin: false,
    password: "some current user password"
  }

  def fixture(:current_user) do
    {:ok, current_user} = Accounts.create_user(@current_user_attrs)
    current_user
  end

  def fixture(:account) do
    {:ok, account} = Accounts.create_account_for_user(:current_user, @create_attrs)
    account
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: insert(:user)}
  end

  describe "index" do
    test "lists all accounts for current user", %{conn: _conn, current_user: _current_user} do
    end
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: _conn, current_user: _current_user} do
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.account_path(conn, :create), account: @invalid_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end
  end
end
