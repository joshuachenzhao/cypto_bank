defmodule CyptoBank.AdjustmentsTest do
  use CyptoBank.DataCase

  alias CyptoBank.Adjustments

  describe "adjustments" do
    alias CyptoBank.Adjustments.Adjustment

    @valid_attrs %{amount: 42, note: "some note", status: "some status"}
    @update_attrs %{amount: 43, note: "some updated note", status: "some updated status"}
    @invalid_attrs %{amount: nil, note: nil, status: nil}

    def adjustment_fixture(attrs \\ %{}) do
      {:ok, adjustment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Adjustments.create_adjustment()

      adjustment
    end

    test "list_adjustments/0 returns all adjustments" do
      adjustment = adjustment_fixture()
      assert Adjustments.list_adjustments() == [adjustment]
    end

    test "get_adjustment!/1 returns the adjustment with given id" do
      adjustment = adjustment_fixture()
      assert Adjustments.get_adjustment!(adjustment.id) == adjustment
    end

    test "create_adjustment/1 with valid data creates a adjustment" do
      assert {:ok, %Adjustment{} = adjustment} = Adjustments.create_adjustment(@valid_attrs)
      assert adjustment.amount == 42
      assert adjustment.note == "some note"
      assert adjustment.status == "some status"
    end

    test "create_adjustment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Adjustments.create_adjustment(@invalid_attrs)
    end

    test "update_adjustment/2 with valid data updates the adjustment" do
      adjustment = adjustment_fixture()
      assert {:ok, %Adjustment{} = adjustment} = Adjustments.update_adjustment(adjustment, @update_attrs)
      assert adjustment.amount == 43
      assert adjustment.note == "some updated note"
      assert adjustment.status == "some updated status"
    end

    test "update_adjustment/2 with invalid data returns error changeset" do
      adjustment = adjustment_fixture()
      assert {:error, %Ecto.Changeset{}} = Adjustments.update_adjustment(adjustment, @invalid_attrs)
      assert adjustment == Adjustments.get_adjustment!(adjustment.id)
    end

    test "delete_adjustment/1 deletes the adjustment" do
      adjustment = adjustment_fixture()
      assert {:ok, %Adjustment{}} = Adjustments.delete_adjustment(adjustment)
      assert_raise Ecto.NoResultsError, fn -> Adjustments.get_adjustment!(adjustment.id) end
    end

    test "change_adjustment/1 returns a adjustment changeset" do
      adjustment = adjustment_fixture()
      assert %Ecto.Changeset{} = Adjustments.change_adjustment(adjustment)
    end
  end
end
