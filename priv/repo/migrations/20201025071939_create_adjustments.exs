defmodule CyptoBank.Repo.Migrations.CreateAdjustments do
  use Ecto.Migration
  alias CyptoBank.Adjustments.Adjustment.AdjustmentStatus

  def up do
    AdjustmentStatus.create_type()

    create table(:adjustments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :amount, :integer, null: false
      add :status, :adjustment_status, null: false, default: "pending"
      add :memo, :string
      add :admin_id, references(:users, on_delete: :nothing, type: :binary_id)

      add :original_ledger_id, references(:ledgers, on_delete: :nothing, type: :binary_id),
        null: false

      add :adjust_ledger_id, references(:ledgers, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:adjustments, [:admin_id])
    create index(:adjustments, [:original_ledger_id])
    create index(:adjustments, [:adjust_ledger_id])
  end

  def down do
    drop table(:adjustments)

    AdjustmentStatus.drop_type()
  end
end
