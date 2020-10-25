defmodule CyptoBank.AdjustmentsTest do
  use CyptoBank.DataCase
  import CyptoBank.Factory

  alias CyptoBank.Adjustments

  describe "adjustments" do
    alias CyptoBank.Adjustments.Adjustment

    test "check_no_existing_adjustment/1 returns error when ledger has adjustment" do
      adjustment = insert(:adjustment, original_ledger: insert(:ledger))

      id = adjustment.original_ledger.id

      assert {:error, :adjustment_already_exist} = Adjustments.check_no_existing_adjustment(id)
    end

    test "check_no_existing_adjustment/1 returns ok when ledger has not adjustment" do
      ledger = insert(:ledger)
      id = ledger.id

      assert {:ok, id} = Adjustments.check_no_existing_adjustment(id)
    end

    test "approve_adjustment/2 successful" do
      ledger = insert(:ledger)
      adjustment = insert(:adjustment)
      adjustment_id = insert(:adjustment).id
      admin_id = insert(:admin).id

      assert {:ok, _} = Adjustments.approve_adjustment(adjustment_id, admin_id)
    end
  end
end
