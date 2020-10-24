defmodule CyptoBank.TransactionsTest do
  use CyptoBank.DataCase

  alias CyptoBank.Transactions

  describe "ledgers" do
    alias CyptoBank.Transactions.Ledger

    @valid_attrs %{amount: 42, note: "some note", type: "some type"}
    @update_attrs %{amount: 43, note: "some updated note", type: "some updated type"}
    @invalid_attrs %{amount: nil, note: nil, type: nil}

    def ledger_fixture(attrs \\ %{}) do
      {:ok, ledger} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transactions.create_ledger()

      ledger
    end

    test "list_ledgers/0 returns all ledgers" do
      ledger = ledger_fixture()
      assert Transactions.list_ledgers() == [ledger]
    end

    test "get_ledger!/1 returns the ledger with given id" do
      ledger = ledger_fixture()
      assert Transactions.get_ledger!(ledger.id) == ledger
    end

    test "create_ledger/1 with valid data creates a ledger" do
      assert {:ok, %Ledger{} = ledger} = Transactions.create_ledger(@valid_attrs)
      assert ledger.amount == 42
      assert ledger.note == "some note"
      assert ledger.type == "some type"
    end

    test "create_ledger/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transactions.create_ledger(@invalid_attrs)
    end

    test "update_ledger/2 with valid data updates the ledger" do
      ledger = ledger_fixture()
      assert {:ok, %Ledger{} = ledger} = Transactions.update_ledger(ledger, @update_attrs)
      assert ledger.amount == 43
      assert ledger.note == "some updated note"
      assert ledger.type == "some updated type"
    end

    test "update_ledger/2 with invalid data returns error changeset" do
      ledger = ledger_fixture()
      assert {:error, %Ecto.Changeset{}} = Transactions.update_ledger(ledger, @invalid_attrs)
      assert ledger == Transactions.get_ledger!(ledger.id)
    end

    test "delete_ledger/1 deletes the ledger" do
      ledger = ledger_fixture()
      assert {:ok, %Ledger{}} = Transactions.delete_ledger(ledger)
      assert_raise Ecto.NoResultsError, fn -> Transactions.get_ledger!(ledger.id) end
    end

    test "change_ledger/1 returns a ledger changeset" do
      ledger = ledger_fixture()
      assert %Ecto.Changeset{} = Transactions.change_ledger(ledger)
    end
  end
end
