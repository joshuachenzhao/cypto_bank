defmodule CyptoBankWeb.AdjustmentController do
  use CyptoBankWeb, :controller

  alias CyptoBank.Adjustments
  alias CyptoBank.Adjustments.Adjustment

  action_fallback CyptoBankWeb.FallbackController

  def index(conn, _params) do
    adjustments = Adjustments.list_adjustments()
    render(conn, "index.json", adjustments: adjustments)
  end

  def create(conn, %{"adjustment" => adjustment_params}) do
    with {:ok, %Adjustment{} = adjustment} <- Adjustments.create_adjustment(adjustment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.adjustment_path(conn, :show, adjustment))
      |> render("show.json", adjustment: adjustment)
    end
  end

  def show(conn, %{"id" => id}) do
    adjustment = Adjustments.get_adjustment!(id)
    render(conn, "show.json", adjustment: adjustment)
  end

  def update(conn, %{"id" => id, "adjustment" => adjustment_params}) do
    adjustment = Adjustments.get_adjustment!(id)

    with {:ok, %Adjustment{} = adjustment} <- Adjustments.update_adjustment(adjustment, adjustment_params) do
      render(conn, "show.json", adjustment: adjustment)
    end
  end

  def delete(conn, %{"id" => id}) do
    adjustment = Adjustments.get_adjustment!(id)

    with {:ok, %Adjustment{}} <- Adjustments.delete_adjustment(adjustment) do
      send_resp(conn, :no_content, "")
    end
  end
end
