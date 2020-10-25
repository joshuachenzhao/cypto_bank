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
  end
end
