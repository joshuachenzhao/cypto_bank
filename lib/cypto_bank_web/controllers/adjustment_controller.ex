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
        "account_id" => account_id,
        "adjustment" => %{"original_ledger_id" => original_ledger_id} = adjustment_params
      }) do
    with {:ok, _account} <- account_ownership_check(conn, account_id),
         {:ok, _} <- Adjustments.check_no_existing_adjustment(original_ledger_id),
         {:ok, %Adjustment{} = adjustment} <-
           Adjustments.create_adjustment(adjustment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.adjustment_path(conn, :show, adjustment))
      |> render("show.json", adjustment: adjustment)
    end
  end

  def show(conn, %{"adjustment_id" => id}) do
    with {:ok, _user} <- verify_admin_access(conn) do
      adjustment = Adjustments.get_adjustment!(id)
      render(conn, "show.json", adjustment: adjustment)
    end
  end

  def approve(conn, %{"adjustment_id" => id}) do
    with {:ok, _user} <- verify_admin_access(conn),
         {:ok, %{close_adjustment_step: adjustment}} <-
           Adjustments.approve_adjustment(id) do
      render(conn, "show.json", adjustment: adjustment)
    end
  end
end
