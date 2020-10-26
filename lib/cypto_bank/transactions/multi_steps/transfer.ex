defmodule CyptoBank.Transactions.MultiSteps.Transfer do
  import Ecto.Query, warn: false

  alias CyptoBank.Accounts.Account
  alias CyptoBank.Transactions

  def retrieve_accounts(send_acc_id, receive_acc_id) do
    fn repo, _ ->
      case from(acc in Account, where: acc.id in [^send_acc_id, ^receive_acc_id])
           |> repo.all() do
        [send_acc, receive_acc] -> {:ok, {send_acc, receive_acc}}
        _ -> {:error, :account_not_found}
      end
    end
  end

  def verify_balances(transfer_amount) do
    fn _repo, %{retrieve_accounts_step: {send_acc, receive_acc}} ->
      if send_acc.balance < transfer_amount,
        do: {:error, :balance_too_low},
        else: {:ok, {transfer_amount, send_acc, receive_acc}}
    end
  end

  def create_send_ledger(_repo, %{verify_balances_step: {transfer_amount, send_acc, _}}) do
    %{amount: transfer_amount, account_id: send_acc.id, type: :transfer_pay}
    |> Transactions.create_ledger()
  end

  def subtract_from_send_acc(repo, %{verify_balances_step: {verified_amount, send_acc, _}}) do
    send_acc
    |> Account.changeset(%{balance: send_acc.balance - verified_amount})
    |> repo.update()
  end

  def create_receive_ledger(_repo, %{verify_balances_step: {transfer_amount, _, receive_acc}}) do
    %{
      amount: transfer_amount,
      account_id: receive_acc.id,
      type: :transfer_receive
    }
    |> Transactions.create_ledger()
  end

  def add_to_receive_acc(repo, %{verify_balances_step: {verified_amount, _, receive_acc}}) do
    receive_acc
    |> Account.changeset(%{balance: receive_acc.balance + verified_amount})
    |> repo.update()
  end
end
