defmodule CyptoBank.Adjustments.MultiSteps.Approve do
  @moduledoc """
  Ecto.Multi steps for CyptoBank.Adjustments.approve_adjustment/2
  """
  import Ecto.Query, warn: false

  alias CyptoBank.Accounts.Account
  alias CyptoBank.Adjustments.Adjustment
  alias CyptoBank.Transactions
  alias CyptoBank.Transactions.Ledger

  def retrieve_adjustment(adjustment_id) do
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

  def retrieve_account() do
    fn repo, %{retrieve_adjustment_step: {adjustment, account_id}} ->
      case from(acc in Account, where: acc.id == ^account_id) |> repo.one() do
        nil -> {:error, :account_not_found}
        account -> {:ok, {account, adjustment}}
      end
    end
  end

  def retrieve_ledger() do
    fn repo, %{retrieve_account_step: {account, adjustment}} ->
      case from(ledger in Ledger, where: ledger.id == ^adjustment.original_ledger_id)
           |> repo.one() do
        nil -> {:error, :original_ledger_not_found}
        ledger -> {:ok, {account, adjustment, ledger}}
      end
    end
  end

  def verify_ledger_type() do
    fn _repo, %{retrieve_ledger_step: {_account, _adjustment, ledger}} ->
      if ledger.type in [:deposit, :withdrawal],
        do: {:ok, {ledger}},
        else:
          {:error,
           {:unspport_ledger_type_for_adjustment,
            "Adjustment only available for deposit and withdrawal transactions"}}
    end
  end

  def verify_adjustment_amount() do
    fn _repo, %{retrieve_ledger_step: {account, adjustment, ledger}} ->
      formated_adjustment_amount = format_double_entry_amount(ledger.type, adjustment.amount)
      adjustment_ledger_amount = formated_adjustment_amount - ledger.amount

      if formated_adjustment_amount + account.balance - ledger.amount < 0,
        do:
          {:error,
           {:no_sufficient_balance,
            "Current account balance are not sufficient for this adjustment"}},
        else: {:ok, {adjustment_ledger_amount, account, adjustment, ledger}}
    end
  end

  def create_adjustment_ledger(_repo, %{
        verify_adjustment_amount_step: {amount, account, adjustment, ledger}
      }) do
    ledger_params = %{amount: amount, account_id: account.id, type: :adjustment}

    case ledger_params |> Transactions.create_ledger() do
      {:ok, %Ledger{} = adjust_ledger} ->
        {:ok, {amount, account, adjustment, ledger, adjust_ledger}}

      error ->
        error
    end
  end

  def adjust_account_balance(repo, %{
        verify_adjustment_amount_step: {amount, account, _adjustment, _ledger}
      }) do
    account
    |> Account.changeset(%{balance: account.balance + amount})
    |> repo.update()
  end

  def close_adjustment(admin_id) do
    fn repo,
       %{
         create_adjustment_ledger_step: {_amount, _account, adjustment, _ledger, adjust_ledger}
       } ->
      adjustment
      |> Adjustment.update_changeset(%{
        status: :success,
        adjust_ledger_id: adjust_ledger.id,
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
