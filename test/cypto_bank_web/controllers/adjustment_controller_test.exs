defmodule CyptoBankWeb.AdjustmentControllerTest do
  use CyptoBankWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all adjustments for admin/operation team", %{conn: _conn} do
    end
  end

  describe "create adjustment" do
    test "renders adjustment when data is valid", %{conn: _conn} do
    end

    test "renders errors when data is invalid", %{conn: _conn} do
    end
  end

  describe "approve an adjustment" do
    test "renders adjustment when approve", %{conn: _conn} do
    end

    test "renders errors when data is invalid", %{conn: _conn} do
    end
  end
end
