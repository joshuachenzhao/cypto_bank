defmodule CyptoBank.Transactions do
  @moduledoc """
  The Transactions context.
  """
  import Ecto.Query, warn: false
  import CyptoBank.Helpers.Query
  alias Ecto.Multi

  alias CyptoBank.Repo

  alias CyptoBank.Accounts.Account
  alias CyptoBank.Transactions.Ledger

  def list_ledgers do
    Repo.all(Ledger)
  end

  def list_ledgers_for_account(account_id) do
    Ledger
    |> query_join(:account, :id, account_id)
    |> Repo.all()
  end

  def get_ledger!(id), do: Repo.get!(Ledger, id)

  def get_ledger_for_account!(transaction_id, account_id) do
    Ledger
    |> query_join(:account, :id, account_id)
    |> Repo.get!(transaction_id)
  end

  def create_ledger(attrs \\ %{}) do
    %Ledger{}
    |> Ledger.changeset(attrs)
    |> Repo.insert()
  end

  def update_ledger(%Ledger{} = ledger, attrs) do
    ledger
    |> Ledger.changeset(attrs)
    |> Repo.update()
  end

  def change_ledger(%Ledger{} = ledger, attrs \\ %{}) do
    Ledger.changeset(ledger, attrs)
  end

  @doc """
  Deposite money of given amount to account with account_id
  """
  def deposite(amount, account_id) do
    Multi.new()
    |> Multi.run(:retrieve_account_step, retrieve_account(amount, account_id))
    |> Multi.run(:create_deposit_ledger_step, &create_deposit_ledger/2)
    |> Multi.run(:add_to_account_step, &add_to_account/2)
    |> Repo.transaction()
  end

  @doc """
  withdrawal money of given amount to account with account_id
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

  defp retrieve_account(amount, account_id) do
    # fn _repo, _ ->
    fn repo, _ ->
      case from(acc in Account, where: acc.id == ^account_id) |> repo.one() do
        # case Accounts.get_account!(account_id) do
        nil -> {:error, :account_not_found}
        account -> {:ok, {amount, account}}
      end
    end
  end

  defp create_deposit_ledger(_repo, %{retrieve_account_step: {amount, account}}) do
    %{amount: amount, account_id: account.id, type: :deposit}
    |> create_ledger()
  end

  defp create_withdrawal_ledger(_repo, %{retrieve_account_step: {amount, account}}) do
    %{amount: amount, account_id: account.id, type: :withdrawal}
    |> create_ledger()
  end

  defp add_to_account(repo, %{retrieve_account_step: {amount, account}}) do
    account
    |> Account.changeset(%{balance: account.balance + amount})
    |> repo.update()
  end

  defp substract_from_account(repo, %{retrieve_account_step: {amount, account}}) do
    account
    |> Account.changeset(%{balance: account.balance - amount})
    |> repo.update()
  end

  defp retrieve_accounts(send_acc_id, receive_acc_id) do
    fn repo, _ ->
      case from(acc in Account, where: acc.id in [^send_acc_id, ^receive_acc_id]) |> repo.all() do
        [send_acc, receive_acc] -> {:ok, {send_acc, receive_acc}}
        _ -> {:error, :account_not_found}
      end
    end
  end

  defp verify_balance() do
    fn _repo, %{retrieve_account_step: {amount, account}} ->
      if account.balance < amount,
        do: {:error, :balance_too_low},
        else: {:ok, {amount, account}}
    end
  end

  defp verify_balances(transfer_amount) do
    fn _repo, %{retrieve_accounts_step: {send_acc, receive_acc}} ->
      if send_acc.balance < transfer_amount,
        do: {:error, :balance_too_low},
        else: {:ok, {transfer_amount, send_acc, receive_acc}}
    end
  end

  defp create_send_ledger(_repo, %{verify_balances_step: {transfer_amount, send_acc, _}}) do
    %{amount: transfer_amount, account_id: send_acc.id, type: :transfer_pay}
    |> create_ledger()
  end

  defp subtract_from_send_acc(repo, %{verify_balances_step: {verified_amount, send_acc, _}}) do
    send_acc
    |> Account.changeset(%{balance: send_acc.balance - verified_amount})
    |> repo.update()
  end

  defp create_receive_ledger(_repo, %{verify_balances_step: {transfer_amount, _, receive_acc}}) do
    %{
      amount: transfer_amount,
      account_id: receive_acc.id,
      type: :transfer_receive
    }
    |> create_ledger()
  end

  defp add_to_receive_acc(repo, %{verify_balances_step: {verified_amount, _, receive_acc}}) do
    receive_acc
    |> Account.changeset(%{balance: receive_acc.balance + verified_amount})
    |> repo.update()
  end
end
