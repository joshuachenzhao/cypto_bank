defmodule CyptoBank.Repo.Migrations.CreateLedgers do
  use Ecto.Migration
  alias CyptoBank.Transactions.Ledger.LedgerType

  def up do
    LedgerType.create_type()

    create table(:ledgers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :integer, null: false
      add :type, :ledger_type, null: false
      add :memo, :string
      add :account_id, references(:accounts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:ledgers, [:account_id])
  end

  def down do
    drop table(:ledgers)

    LedgerType.drop_type()
  end
end
