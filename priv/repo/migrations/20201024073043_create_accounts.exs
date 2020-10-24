defmodule CyptoBank.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :balance, :integer, default: 0
      add :user_id, references(:users, on_delete: :restrict, type: :binary_id)

      timestamps()
    end

    create index(:accounts, [:user_id])
  end
end
