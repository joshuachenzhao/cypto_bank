defmodule CyptoBank.TransactionsTest do
  use CyptoBank.DataCase

  import Ecto.Query, warn: false
  import CyptoBank.Factory

  alias CyptoBank.Repo

  describe "ledgers" do
    alias CyptoBank.Accounts.Account
    alias CyptoBank.Transactions
    alias CyptoBank.Transactions.Ledger

    test "list_ledgers_for_account/1 returns a ledger for account" do
      account = insert(:account)

      deposits = insert_list(3, :ledger, account: account, type: :deposit)
      withdrawals = insert_list(3, :ledger, account: account, type: :withdrawal)
      transfers = insert_list(3, :ledger, account: account, type: :transfer_pay)

      ledgers = deposits ++ withdrawals ++ transfers

      assert ledgers |> get_fields(:id) ==
               Transactions.list_ledgers_for_account(account.id) |> get_fields(:id)
    end

    test "get_ledger_for_account!/2 returns a ledger of given account" do
      account = insert(:account)
      ledger = insert(:ledger, account: account, type: :deposit)

      assert ledger.id == Transactions.get_ledger_for_account!(ledger.id, account.id).id
    end

    test "deposit/2 returns a ledger with correct amount, type, increase account balance by amount" do
      amount = 10_000
      account = insert(:account, balance: 0)

      assert {:ok, %{create_deposit_ledger_step: ledger}} =
               Transactions.deposit(amount, account.id)

      ledger = ledger |> Repo.preload(:account)

      assert ledger.type == :deposit
      assert ledger.amount == 10_000
      assert ledger.account.balance == 10_000
    end

    test "withdrawal/2 returns a ledger with correct amount, type, decrease account balance by amount" do
      amount = 10_000
      account = insert(:account, balance: 20_000)

      assert {:ok, %{create_withdrawal_ledger_step: ledger}} =
               Transactions.withdrawal(amount, account.id)

      ledger = ledger |> Repo.preload(:account)

      assert ledger.type == :withdrawal
      assert ledger.amount == -10_000
      assert ledger.account.balance == 10_000
    end

    test "withdrawal/2 fails for insufficient account balance" do
      amount = 30_000
      account = insert(:account, balance: 20_000)
      ledgers = Ledger |> Repo.all()

      assert {:error, :verify_balance_step, :balance_too_low, _} =
               Transactions.withdrawal(amount, account.id)

      account_after = from(acc in Account, where: acc.id == ^account.id) |> Repo.one()
      ledgers_after = Ledger |> Repo.all()

      assert ledgers == ledgers_after
      assert account_after.balance == account.balance
    end

    test "transfer/3 returns 2 ledgers with correct amount" do
      amount = 10_000

      send_account = insert(:account, balance: 20_000)
      receive_account = insert(:account, balance: 0)

      assert {:ok,
              %{
                create_send_ledger_step: send_ledger,
                create_receive_ledger_step: receive_leger
              }} = Transactions.transfer(amount, send_account.id, receive_account.id)

      send_ledger = send_ledger |> Repo.preload(:account)
      receive_ledger = receive_leger |> Repo.preload(:account)

      assert send_ledger.type == :transfer_pay
      assert send_ledger.amount == -10_000
      assert send_ledger.account.balance == 10_000

      assert receive_ledger.type == :transfer_receive
      assert receive_ledger.amount == 10_000
      assert receive_ledger.account.balance == 10_000
    end

    test "transfer/3 fails for insufficient account balance" do
      amount = 100_000
      send_account = insert(:account, balance: 20_000)
      receive_account = insert(:account, balance: 0)
      ledgers = Ledger |> Repo.all()

      assert {:error, :verify_balances_step, :balance_too_low, _} =
               Transactions.transfer(amount, send_account.id, receive_account.id)

      send_account_after = from(acc in Account, where: acc.id == ^send_account.id) |> Repo.one()

      receive_account_after =
        from(acc in Account, where: acc.id == ^receive_account.id) |> Repo.one()

      ledgers_after = Ledger |> Repo.all()

      assert ledgers == ledgers_after
      assert send_account_after.balance == send_account.balance
      assert receive_account_after.balance == receive_account.balance
    end
  end
end
