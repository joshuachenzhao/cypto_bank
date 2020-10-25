defmodule CyptoBank.TransactionsTest do
  use CyptoBank.DataCase
  import CyptoBank.Factory
  alias CyptoBank.Transactions

  describe "ledgers" do
    alias CyptoBank.Transactions.Ledger
    alias CyptoBank.Accounts.User

    test "list_ledgers_for_account/1 returns a ledger for account" do
      account = insert(:account)
      ledgers = insert_list(3, :ledger, account: account)

      assert ledgers = Transactions.list_ledgers_for_account(account.id)
    end

    test "get_ledger_for_account!/2 returns a ledgers" do
      account = insert(:account)
      ledger = insert(:ledger, account: account)

      assert ledger = Transactions.get_ledger_for_account!(ledger.id, account.id)
    end

    test "deposit/2 returns a ledger with correct amount" do
      amount = 10_000
      account = insert(:account, balance: 0)
      ledger = insert(:ledger, account: account, amount: 10_000, type: :deposit)

      assert {:ok, %{create_deposit_ledger_step: ledger}} =
               Transactions.deposite(amount, account.id)
    end

    test "withdrawal/2 returns a ledger with correct amount" do
      amount = 10_000
      account = insert(:account, balance: 20_000)
      ledger = insert(:ledger, account: account, amount: 10_000, type: :deposit)

      assert {:ok, %{create_withdrawal_ledger_step: ledger}} =
               Transactions.withdrawal(amount, account.id)
    end

    test "transfer/3 returns 2 ledgers with correct amount" do
      amount = 10_000
      send_account = insert(:account, balance: 30_000)
      receive_account = insert(:account, balance: 10_000)
      send_ledger = insert(:ledger, account: send_account, amount: -10_000, type: :transfer_pay)

      receive_ledger =
        insert(:ledger, account: receive_account, amount: 10_000, type: :transfer_receive)

      assert {:ok,
              %{
                create_send_ledger_step: send_ledger,
                create_receive_ledger_step: receive_leger
              }} = Transactions.transfer(amount, send_account.id, receive_account.id)
    end
  end
end
