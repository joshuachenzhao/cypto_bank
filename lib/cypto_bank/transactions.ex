defmodule CyptoBank.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias CyptoBank.Repo

  alias CyptoBank.Accounts.Account
  alias CyptoBank.Transactions.Ledger

  def list_ledgers do
    Repo.all(Ledger)
  end

  def get_ledger!(id), do: Repo.get!(Ledger, id)

  def create_ledger(attrs \\ %{}) do
    %Ledger{}
    |> Ledger.changeset(attrs)
    |> Repo.insert()
  end

  def update_ledger(%Ledger{} = ledger, attrs) do
    ledger
    |> Ledger.changeset(attrs)
    |> Repo.update()
  end

  def delete_ledger(%Ledger{} = ledger) do
    Repo.delete(ledger)
  end

  def change_ledger(%Ledger{} = ledger, attrs \\ %{}) do
    Ledger.changeset(ledger, attrs)
  end

  def transfer(amount, send_acc_id, receive_acc_id) do
    Repo.transaction(fn ->
      [acc_a, acc_b] =
        from(acc in Account, where: acc.id in [^send_acc_id, ^receive_acc_id]) |> Repo.all()

      if acc_a.balance < amount, do: Repo.rollback(:balance_too_low)

      update1 = acc_a |> Account.changeset(%{balance: acc_a.balance - amount}) |> Repo.update!()
      update2 = acc_b |> Account.changeset(%{balance: acc_b.balance + amount}) |> Repo.update!()

      {update1, update2}
    end)
  end
end
