defmodule CyptoBankWeb.AdjustmentController do
  use CyptoBankWeb, :controller
  import CyptoBankWeb.Helpers, only: [verify_admin_access: 1, verify_account_access: 2]

  alias CyptoBank.Adjustments
  alias CyptoBank.Adjustments.Adjustment

  action_fallback CyptoBankWeb.FallbackController

  @doc """
  Index all adjustments for admin/operation team
  """
  def index(conn, _params) do
    with {:ok, _user} <- verify_admin_access(conn) do
      adjustments = Adjustments.list_adjustments()
      render(conn, "index.json", adjustments: adjustments)
    end
  end

  @doc """
  Create an new adjustment request by current user for admin/operation team.
  1. check account used to create adjustment request is owned by current user.
  2. check if there's already an adjustment request for target transaction/ledger.
  """
  def create(conn, %{
        "account_id" => account_id,
        "adjustment" => %{"original_ledger_id" => original_ledger_id} = adjustment_params
      }) do
    with {:ok, _account} <- verify_account_access(conn, account_id),
         {:ok, _} <- Adjustments.check_no_existing_adjustment(original_ledger_id),
         {:ok, %Adjustment{} = adjustment} <-
           Adjustments.create_adjustment(adjustment_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.adjustment_path(conn, :show, adjustment))
      |> render("show.json", adjustment: adjustment)
    end
  end

  @doc """
  Show an adjustment request for admin/operation use only.
  """
  def show(conn, %{"adjustment_id" => id}) do
    with {:ok, _user} <- verify_admin_access(conn) do
      adjustment = Adjustments.get_adjustment!(id)
      render(conn, "show.json", adjustment: adjustment)
    end
  end

  @doc """
  Approve an adjustment for admin/operation use only.
  1. verify admin access
  2. using Ecto.Multi transactions to ensure data safty
  3. read more details on CyptoBank.Adjustments.approve_adjustment/2
  """
  def approve(conn, %{"adjustment_id" => id}) do
    with {:ok, admin} <- verify_admin_access(conn),
         {:ok, %{close_adjustment_step: adjustment}} <-
           Adjustments.approve_adjustment(id, admin.id) do
      render(conn, "show.json", adjustment: adjustment)
    end
  end

  def decline(conn, %{"adjustment_id" => id}) do
    with {:ok, admin} <- verify_admin_access(conn),
         {:ok, %{close_adjustment_step: adjustment}} <-
           Adjustments.decline_adjustment(id, admin.id) do
      render(conn, "show.json", adjustment: adjustment)
    end
  end
end
