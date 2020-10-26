defmodule CyptoBank.Transactions do
  @moduledoc """
  The Transactions context.
  """
  import Ecto.Query, warn: false
  import CyptoBank.Helpers.Query
  import CyptoBank.Transactions.MultiSteps.{DepositWithdrawal, Transfer}

  alias Ecto.Multi

  alias CyptoBank.Repo
  alias CyptoBank.Transactions.Ledger

  @doc """
  Deposit money of given amount to account with account_id
  """
  def deposit(amount, account_id) do
    Multi.new()
    |> Multi.run(:retrieve_account_step, retrieve_account(amount, account_id))
    |> Multi.run(:create_deposit_ledger_step, &create_deposit_ledger/2)
    |> Multi.run(:add_to_account_step, &add_to_account/2)
    |> Repo.transaction()
  end

  @doc """
  Withdrawal money of given amount to account with account_id
  """
  def withdrawal(amount, account_id) do
    Multi.new()
    |> Multi.run(:retrieve_account_step, retrieve_account(amount, account_id))
    |> Multi.run(:verify_balance_step, verify_balance())
    |> Multi.run(:create_withdrawal_ledger_step, &create_withdrawal_ledger/2)
    |> Multi.run(:substract_from_account_step, &substract_from_account/2)
    |> Repo.transaction()
  end

  @doc """
  Transfer money of given amount from send account to receive account
  """
  def transfer(amount, send_acc_id, receive_acc_id) do
    Multi.new()
    |> Multi.run(:retrieve_accounts_step, retrieve_accounts(send_acc_id, receive_acc_id))
    |> Multi.run(:verify_balances_step, verify_balances(amount))
    |> Multi.run(:create_send_ledger_step, &create_send_ledger/2)
    |> Multi.run(:subtract_from_send_acc_step, &subtract_from_send_acc/2)
    |> Multi.run(:create_receive_ledger_step, &create_receive_ledger/2)
    |> Multi.run(:add_to_receive_acc_step, &add_to_receive_acc/2)
    |> Repo.transaction()
  end

  @doc """
  Index all ledgers belongs to account with id
  """
  def list_ledgers_for_account(account_id) do
    Ledger
    |> query_join(:account, :id, account_id)
    |> Repo.all()
  end

  def get_ledger_for_account!(transaction_id, account_id) do
    Ledger
    |> query_join(:account, :id, account_id)
    |> Repo.get!(transaction_id)
  end

  def list_ledgers do
    Repo.all(Ledger)
  end

  def get_ledger!(id), do: Repo.get!(Ledger, id)

  def create_ledger(attrs \\ %{}) do
    %Ledger{}
    |> Ledger.changeset(attrs)
    |> Repo.insert()
  end
end
