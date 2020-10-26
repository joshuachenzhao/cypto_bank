defmodule CyptoBankWeb.TransactionControllerTest do
  use CyptoBankWeb.ConnCase

  import CyptoBank.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: insert(:admin)}
  end

  describe "index for admin" do
    test "lists all ledgers", %{conn: conn} do
      get(conn, Routes.transaction_path(conn, :index_for_admin))
    end
  end

  describe "index for account" do
    test "lists all ledgers for an account", %{conn: _conn} do
    end
  end

  describe "show" do
    test "lists all ledgers", %{conn: _conn} do
    end
  end

  describe "deposit" do
    test "renders deposit when data is valid", %{conn: _conn} do
    end

    test "renders errors when data is invalid", %{conn: _conn} do
    end
  end

  describe "withdrawal" do
    test "renders withdrawal when data is valid", %{conn: _conn} do
    end

    test "renders errors when data is invalid", %{conn: _conn} do
    end
  end

  describe "transfer" do
    test "renders transfer when data is valid", %{conn: _conn} do
    end

    test "renders errors when data is invalid", %{conn: _conn} do
    end
  end
end
