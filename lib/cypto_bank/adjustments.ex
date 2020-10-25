defmodule CyptoBank.Adjustments do
  @moduledoc """
  The Adjustments context.
  """

  import Ecto.Query, warn: false
  import CyptoBank.Helpers.Query
  alias Ecto.Multi

  alias CyptoBank.Repo
  alias CyptoBank.Accounts.Account
  alias CyptoBank.Adjustments.Adjustment
  alias CyptoBank.Transactions
  alias CyptoBank.Transactions.Ledger

  def list_adjustments do
    Repo.all(Adjustment)
  end

  # XXX
  def list_adjustments_for_user(account_id) do
    Adjustment
    |> query_join(:account, :id, account_id)
    |> Repo.all()
  end

  def get_adjustment!(id), do: Repo.get!(Adjustment, id)

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

  def decline_adjustment(adjustment_id, admin_id) do
    adjustment_id
    |> get_adjustment!()
    |> Adjustment.update_changeset(%{
      status: :denied,
      admin_id: admin_id
    })
    |> Repo.update()
  end

  defp retrieve_adjustment(adjustment_id) do
    fn repo, _ ->
      case from(
             adjustment in Adjustment,
             where: adjustment.id == ^adjustment_id,
             preload: [:original_ledger]
           )
           |> repo.one() do
        %Adjustment{status: :pending} = adjustment ->
          {:ok, {adjustment, adjustment.original_ledger.account_id}}

        %Adjustment{status: status} ->
          {:error,
           {:adjustment_has_been_processed,
            "Adjustment has already been processed, status: #{status}"}}

        nil ->
          {:error, :adjustment_not_found}
      end
    end
  end

  defp retrieve_account() do
    fn repo, %{retrieve_adjustment_step: {adjustment, account_id}} ->
      case from(acc in Account, where: acc.id == ^account_id) |> repo.one() do
        nil -> {:error, :account_not_found}
        account -> {:ok, {account, adjustment}}
      end
    end
  end

  defp retrieve_ledger() do
    fn repo, %{retrieve_account_step: {account, adjustment}} ->
      case from(ledger in Ledger, where: ledger.id == ^adjustment.original_ledger_id)
           |> repo.one() do
        nil -> {:error, :original_ledger_not_found}
        ledger -> {:ok, {account, adjustment, ledger}}
      end
    end
  end

  defp verify_ledger_type() do
    fn _repo, %{retrieve_ledger_step: {_account, _adjustment, ledger}} ->
      if ledger.type in [:deposit, :withdrawal],
        do: {:ok, {ledger}},
        else: {:error, :unspport_ledger_type_for_adjustment}
    end
  end

  defp verify_adjustment_amount() do
    fn _repo, %{retrieve_ledger_step: {account, adjustment, ledger}} ->
      formated_adjustment_amount = format_double_entry_amount(ledger.type, adjustment.amount)
      adjustment_ledger_amount = formated_adjustment_amount - ledger.amount

      if formated_adjustment_amount + account.balance - ledger.amount < 0,
        do: {:error, :no_sufficient_balance},
        else: {:ok, {adjustment_ledger_amount, account, adjustment, ledger}}
    end
  end

  defp create_adjustment_ledger(_repo, %{
         verify_adjustment_amount_step: {amount, account, adjustment, ledger}
       }) do
    with {:ok, %Ledger{} = patched_ledger} <-
           %{amount: amount, account_id: account.id, type: :adjustment}
           |> Transactions.create_ledger() do
      {:ok, {amount, account, adjustment, ledger, patched_ledger}}
    else
      error -> error
    end
  end

  defp adjust_account_balance(repo, %{
         verify_adjustment_amount_step: {amount, account, _adjustment, _ledger}
       }) do
    account
    |> Account.changeset(%{balance: account.balance + amount})
    |> repo.update()
  end

  defp close_adjustment(admin_id) do
    fn repo,
       %{
         create_adjustment_ledger_step: {_amount, _account, adjustment, _ledger, patched_ledger}
       } ->
      adjustment
      |> Adjustment.update_changeset(%{
        status: :success,
        adjust_ledger_id: patched_ledger.id,
        admin_id: admin_id
      })
      |> repo.update()
    end
  end

  def format_double_entry_amount(:deposit, amount), do: abs(amount)
  def format_double_entry_amount(:transfer_receive, amount), do: abs(amount)
  def format_double_entry_amount(:withdrawal, amount), do: -abs(amount)
  def format_double_entry_amount(:transfer_pay, amount), do: -abs(amount)
end
