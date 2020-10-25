defmodule CyptoBankWeb.AdjustmentControllerTest do
  use CyptoBankWeb.ConnCase

  alias CyptoBank.Adjustments
  alias CyptoBank.Adjustments.Adjustment

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:adjustment) do
    {:ok, adjustment} = Adjustments.create_adjustment(@create_attrs)
    adjustment
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all adjustments", %{conn: conn} do
      conn = get(conn, Routes.adjustment_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create adjustment" do
    test "renders adjustment when data is valid", %{conn: conn} do
      conn = post(conn, Routes.adjustment_path(conn, :create), adjustment: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.adjustment_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.adjustment_path(conn, :create), adjustment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update adjustment" do
    setup [:create_adjustment]

    test "renders adjustment when data is valid", %{conn: conn, adjustment: %Adjustment{id: id} = adjustment} do
      conn = put(conn, Routes.adjustment_path(conn, :update, adjustment), adjustment: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.adjustment_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, adjustment: adjustment} do
      conn = put(conn, Routes.adjustment_path(conn, :update, adjustment), adjustment: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete adjustment" do
    setup [:create_adjustment]

    test "deletes chosen adjustment", %{conn: conn, adjustment: adjustment} do
      conn = delete(conn, Routes.adjustment_path(conn, :delete, adjustment))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.adjustment_path(conn, :show, adjustment))
      end
    end
  end

  defp create_adjustment(_) do
    adjustment = fixture(:adjustment)
    %{adjustment: adjustment}
  end
end
