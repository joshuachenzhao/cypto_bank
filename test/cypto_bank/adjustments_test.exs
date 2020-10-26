defmodule CyptoBank.AdjustmentsTest do
  use CyptoBank.DataCase

  import CyptoBank.Factory

  alias CyptoBank.Adjustments

  describe "adjustments" do
    alias CyptoBank.Adjustments.Adjustment

    test "check_no_existing_adjustment/1 returns ok when ledger has not adjustment" do
      id = Ecto.UUID.generate()
      assert {:ok, id} = Adjustments.check_no_existing_adjustment(id)
    end

    test "check_no_existing_adjustment/1 fails and returns error when ledger has adjustment" do
      ledger = insert(:ledger, type: :adjustment)
      adjustment = insert(:adjustment, original_ledger: ledger)

      assert {:error, :adjustment_already_exist} =
               Adjustments.check_no_existing_adjustment(ledger.id)
    end

    test "approve_adjustment/2 returns ok when success" do
      adjustment_amount = 50_000
      original_amount = 30_000
      balance_amount = 100_000
      original_ledger_type = :deposit

      admin = insert(:admin)
      account = insert(:account, balance: balance_amount)

      ledger =
        insert(:ledger, type: original_ledger_type, amount: original_amount, account: account)

      adjustment =
        insert(:adjustment, status: :pending, amount: adjustment_amount, original_ledger: ledger)

      assert {:ok,
              %{
                create_adjustment_ledger_step: {_, _, _, _, adjustment_ledger},
                adjust_account_balance_step: updated_account,
                close_adjustment_step: updated_adjustment
              }} = Adjustments.approve_adjustment(adjustment.id, admin.id)

      # adjustment_ledger |> IO.inspect(label: "foo--------------------------->")
      # updated_account |> IO.inspect(label: "bar--------------------------->")
      # updated_adjustment |> IO.inspect(label: "qua--------------------------->")

      assert adjustment_ledger.account_id == account.id
      assert adjustment_ledger.amount == adjustment_amount - original_amount
      assert adjustment_ledger.type == :adjustment
      assert updated_account.balance == balance_amount - original_amount + adjustment_amount
      assert updated_adjustment.admin_id == admin.id
      assert updated_adjustment.adjust_ledger_id == adjustment_ledger.id
      assert updated_adjustment.status == :success
    end

    test "approve_adjustment/2 fails when adjustment has already been processed with success" do
      adjustment_amount = 50_000
      original_amount = 30_000
      balance_amount = 100_000
      original_ledger_type = :deposit

      admin = insert(:admin)
      account = insert(:account, balance: balance_amount)

      ledger =
        insert(:ledger, type: original_ledger_type, amount: original_amount, account: account)

      adjustment =
        insert(:adjustment, status: :success, amount: adjustment_amount, original_ledger: ledger)

      assert {:error, :retrieve_adjustment_step,
              {:adjustment_has_been_processed,
               "Adjustment has already been processed, status: success"},
              %{}} = Adjustments.approve_adjustment(adjustment.id, admin.id)
    end

    test "approve_adjustment/2 fails when adjustment has already been processed with declined" do
      adjustment_amount = 50_000
      original_amount = 30_000
      balance_amount = 100_000
      original_ledger_type = :deposit

      admin = insert(:admin)
      account = insert(:account, balance: balance_amount)

      ledger =
        insert(:ledger, type: original_ledger_type, amount: original_amount, account: account)

      adjustment =
        insert(:adjustment, status: :declined, amount: adjustment_amount, original_ledger: ledger)

      assert {:error, :retrieve_adjustment_step,
              {:adjustment_has_been_processed,
               "Adjustment has already been processed, status: declined"},
              %{}} = Adjustments.approve_adjustment(adjustment.id, admin.id)
    end

    test "approve_adjustment/2 fails for unsupported transaction type, only support adjustment for deposit and withdrawal" do
      adjustment_amount = 50_000
      original_amount = 30_000
      balance_amount = 100_000
      original_ledger_type = :transfer_pay

      admin = insert(:admin)
      account = insert(:account, balance: balance_amount)

      ledger =
        insert(:ledger, type: original_ledger_type, amount: original_amount, account: account)

      adjustment =
        insert(:adjustment, status: :pending, amount: adjustment_amount, original_ledger: ledger)

      assert {:error, :verify_ledger_type_step,
              {:unspport_ledger_type_for_adjustment,
               "Adjustment only available for deposit and withdrawal transactions"},
              %{}} = Adjustments.approve_adjustment(adjustment.id, admin.id)
    end

    test "approve_adjustment/2 fails when no sufficient account balance when adjust a deposit" do
      adjustment_amount = 30_000
      original_amount = 50_000
      balance_amount = 10_000
      original_ledger_type = :deposit

      admin = insert(:admin)
      account = insert(:account, balance: balance_amount)

      ledger =
        insert(:ledger, type: original_ledger_type, amount: original_amount, account: account)

      adjustment =
        insert(:adjustment, status: :pending, amount: adjustment_amount, original_ledger: ledger)

      assert {:error, :verify_adjustment_amount_step,
              {:no_sufficient_balance,
               "Current account balance are not sufficient for this adjustment"},
              %{}} = Adjustments.approve_adjustment(adjustment.id, admin.id)
    end

    test "approve_adjustment/2 fails when no sufficient account balance when adjust a withdrawal" do
      adjustment_amount = -70_000
      original_amount = -50_000
      balance_amount = 10_000
      original_ledger_type = :withdrawal

      admin = insert(:admin)
      account = insert(:account, balance: balance_amount)

      ledger =
        insert(:ledger, type: original_ledger_type, amount: original_amount, account: account)

      adjustment =
        insert(:adjustment, status: :pending, amount: adjustment_amount, original_ledger: ledger)

      assert {:error, :verify_adjustment_amount_step,
              {:no_sufficient_balance,
               "Current account balance are not sufficient for this adjustment"},
              %{}} = Adjustments.approve_adjustment(adjustment.id, admin.id)
    end
  end
end
