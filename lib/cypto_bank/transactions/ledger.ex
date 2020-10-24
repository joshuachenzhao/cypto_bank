defmodule CyptoBank.Transactions.Ledger do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @permitted_attrs ~w(
    amount
    memo
    type
    account_id
  )a
  @required_attrs ~w(
    amount
    type
    account_id
  )a

  defenum(LedgerType, :ledger_type, [
    :deposit,
    :withdrawal,
    :transfer_pay,
    :transfer_receive,
    :adjustment
  ])

  schema "ledgers" do
    field :amount, :integer, null: false
    field :memo, :string
    field :type, LedgerType, null: false
    field :account_id, :binary_id, null: false

    timestamps()
  end

  @doc false
  def changeset(ledger, attrs) do
    ledger
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> EctoEnum.validate_enum(:type)
  end
end
