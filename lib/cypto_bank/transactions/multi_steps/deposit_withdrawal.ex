defmodule CyptoBank.Transactions.MultiSteps.DepositWithdrawal do
  import Ecto.Query, warn: false

  alias CyptoBank.Accounts.Account
  alias CyptoBank.Transactions

  def retrieve_account(amount, account_id) do
    fn repo, _ ->
      case from(acc in Account, where: acc.id == ^account_id) |> repo.one() do
        nil -> {:error, :account_not_found}
        account -> {:ok, {amount, account}}
      end
    end
  end

  def create_deposit_ledger(_repo, %{retrieve_account_step: {amount, account}}) do
    %{amount: amount, account_id: account.id, type: :deposit}
    |> Transactions.create_ledger()
  end

  def add_to_account(repo, %{retrieve_account_step: {amount, account}}) do
    account
    |> Account.changeset(%{balance: account.balance + amount})
    |> repo.update()
  end

  def create_withdrawal_ledger(_repo, %{retrieve_account_step: {amount, account}}) do
    %{amount: amount, account_id: account.id, type: :withdrawal}
    |> Transactions.create_ledger()
  end

  def substract_from_account(repo, %{retrieve_account_step: {amount, account}}) do
    account
    |> Account.changeset(%{balance: account.balance - amount})
    |> repo.update()
  end

  def verify_balance() do
    fn _repo, %{retrieve_account_step: {amount, account}} ->
      if account.balance < amount,
        do: {:error, :balance_too_low},
        else: {:ok, {amount, account}}
    end
  end
end
