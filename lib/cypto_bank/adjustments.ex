defmodule CyptoBank.Adjustments do
  @moduledoc """
  The Adjustments context.
  """
  import Ecto.Query, warn: false
  import CyptoBank.Adjustments.MultiSteps.Approve

  alias Ecto.Multi

  alias CyptoBank.Repo
  alias CyptoBank.Adjustments.Adjustment

  @doc """
  Check existing adjusment that has the same original_ledger_id, to avoid duplicate 
  adjustment requests
  """
  def check_no_existing_adjustment(ledger_id) do
    from(
      adj in Adjustment,
      where: adj.original_ledger_id == ^ledger_id
    )
    |> Repo.one()
    |> case do
      nil -> {:ok, ledger_id}
      %Adjustment{} -> {:error, :adjustment_already_exist}
    end
  end

  def create_adjustment(attrs \\ %{}) do
    %Adjustment{}
    |> Adjustment.changeset(attrs)
    |> Repo.insert()
  end

  def list_adjustments do
    Repo.all(Adjustment)
  end

  def get_adjustment!(id), do: Repo.get!(Adjustment, id)

  @doc """
  Approve an adjustment
  """
  def approve_adjustment(adjustment_id, admin_id) do
    Multi.new()
    |> Multi.run(:retrieve_adjustment_step, retrieve_adjustment(adjustment_id))
    |> Multi.run(:retrieve_account_step, retrieve_account())
    |> Multi.run(:retrieve_ledger_step, retrieve_ledger())
    |> Multi.run(:verify_ledger_type_step, verify_ledger_type())
    |> Multi.run(:verify_adjustment_amount_step, verify_adjustment_amount())
    |> Multi.run(:create_adjustment_ledger_step, &create_adjustment_ledger/2)
    |> Multi.run(:adjust_account_balance_step, &adjust_account_balance/2)
    |> Multi.run(:close_adjustment_step, close_adjustment(admin_id))
    |> Repo.transaction()
  end

  @doc """
  Decline an adjustment request, currently not assigned to an route yet
  """
  def decline_adjustment(adjustment_id, admin_id) do
    adjustment_id
    |> get_adjustment!()
    |> Adjustment.update_changeset(%{
      status: :declined,
      admin_id: admin_id
    })
    |> Repo.update()
  end
end
