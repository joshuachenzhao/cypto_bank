defmodule CyptoBank.Repo.Migrations.UpdateUsersIsActiveToIsAdmin do
  use Ecto.Migration

  def up do
    rename(table(:users), :is_active, to: :is_admin)
  end

  def down do
    rename(table(:users), :is_admin, to: :is_active)
  end
end
