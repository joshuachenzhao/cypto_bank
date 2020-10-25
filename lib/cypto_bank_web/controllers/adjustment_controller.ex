defmodule CyptoBankWeb.AdjustmentController do
  use CyptoBankWeb, :controller
  import CyptoBankWeb.Helpers, only: [verify_admin_access: 1, account_ownership_check: 2]

  alias CyptoBank.Adjustments
  alias CyptoBank.Adjustments.Adjustment

  action_fallback CyptoBankWeb.FallbackController

  def index(conn, _params) do
    with {:ok, _user} <- verify_admin_access(conn) do
      adjustments = Adjustments.list_adjustments()
      render(conn, "index.json", adjustments: adjustments)
    end
  end

  def create(conn, %{
        "adjustment" =>
          %{
            "amount" => _amount,
            "original_ledger_id" => _original_ledger_id,
            "account_id" => account_id
          } = adjustment_params
      }) do
    with {:ok, _account} <- account_ownership_check(conn, account_id),
         {:ok, %Adjustment{} = adjustment} <- Adjustments.create_adjustment(adjustment_params) do
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

    with {:ok, %Adjustment{} = adjustment} <-
           Adjustments.update_adjustment(adjustment, adjustment_params) do
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
