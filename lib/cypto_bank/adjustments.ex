defmodule CyptoBank.Adjustments do
  @moduledoc """
  The Adjustments context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi

  alias CyptoBank.Repo
  alias CyptoBank.Accounts.Account
  alias CyptoBank.Adjustments.Adjustment
  alias CyptoBank.Transactions
  alias CyptoBank.Transactions.Ledger

  def list_adjustments do
    Repo.all(Adjustment)
  end

  def get_adjustment!(id), do: Repo.get!(Adjustment, id)

  def create_adjustment(attrs \\ %{}) do
    %Adjustment{}
    |> Adjustment.changeset(attrs)
    |> Repo.insert()
  end

  # DOING
  @doc """
  Approve an adjustment
  """
  def approve_adjustment(adjustment_id, amount, account_id, original_ledger_id) do
    Multi.new()
    |> Multi.run(:retrieve_account_step, retrieve_account(amount, account_id))
    |> Multi.run(:retrieve_ledger_step, retrieve_ledger(original_ledger_id))
    |> Multi.run(:retrieve_adjustment_step, retrieve_adjustment(adjustment_id))
    |> Multi.run(:verify_ledger_type_step, verify_ledger_type())
    |> Multi.run(:verify_adjustment_amount_step, verify_adjustment_amount())
    |> Multi.run(:create_adjustment_ledger_step, &create_adjustment_ledger/2)
    |> Multi.run(:adjust_account_balance_step, &adjust_account_balance/2)
    |> Multi.run(:close_adjustment_step, &close_adjustment/2)
    |> Repo.transaction()
  end

  defp retrieve_account(amount, account_id) do
    fn repo, _ ->
      case from(acc in Account, where: acc.id == ^account_id) |> repo.one() do
        nil -> {:error, :account_not_found}
        account -> {:ok, {amount, account}}
      end
    end
  end

  defp retrieve_ledger(ledger_id) do
    fn repo, %{retrieve_account_step: {amount, account}} ->
      case from(ledger in Ledger, where: ledger.id == ^ledger_id) |> repo.one() do
        nil -> {:error, :original_ledger_not_found}
        ledger -> {:ok, {amount, account, ledger}}
      end
    end
  end

  defp retrieve_adjustment(adjustment_id) do
    fn repo, %{retrieve_ledger_step: {amount, account, ledger}} ->
      case from(adjustment in Adjustment, where: adjustment.id == ^adjustment_id) |> repo.one() do
        nil -> {:error, :adjustment_not_found}
        adjustment -> {:ok, {amount, account, adjustment, ledger}}
      end
    end
  end

  defp verify_ledger_type() do
    fn _repo, %{retrieve_ledger_step: {_amount, _account, ledger}} ->
      if ledger.type in [:deposit, :withdrawal],
        do: {:ok, {ledger}},
        else: {:error, :unspport_ledger_type_for_adjustment}
    end
  end

  defp verify_adjustment_amount() do
    fn _repo, %{retrieve_adjustment_step: {amount, account, adjustment, ledger}} ->
      formated_adjustment_amount = format_double_entry_amount(ledger.type, amount)
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

  defp close_adjustment(repo, %{
         create_adjustment_ledger_step: {_amount, account, adjustment, _ledger, patched_ledger}
       }) do
    adjustment
    |> Adjustment.update_changeset(%{
      status: :success,
      adjust_ledger_id: patched_ledger.id,
      admin_id: account.id
    })
    |> repo.update()
  end

  def reject_adjustment() do
  end

  def update_adjustment(%Adjustment{} = adjustment, attrs) do
    adjustment
    |> Adjustment.changeset(attrs)
    |> Repo.update()
  end

  def delete_adjustment(%Adjustment{} = adjustment) do
    Repo.delete(adjustment)
  end

  def change_adjustment(%Adjustment{} = adjustment, attrs \\ %{}) do
    Adjustment.changeset(adjustment, attrs)
  end

  def format_double_entry_amount(:deposit, amount), do: abs(amount)
  def format_double_entry_amount(:transfer_receive, amount), do: abs(amount)
  def format_double_entry_amount(:withdrawal, amount), do: -abs(amount)
  def format_double_entry_amount(:transfer_pay, amount), do: -abs(amount)
end
