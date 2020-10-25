defmodule CyptoBank.Adjustments.Adjustment do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @permitted_attrs ~w(
    amount
    memo
    status
    admin_id
    original_ledger_id
    adjust_ledger_id
  )a
  @required_attrs ~w(
    amount
    status
    original_ledger_id
  )a

  defenum(AdjustmentStatus, :adjustment_status, [
    :pending,
    :success,
    :denied
  ])

  schema "adjustments" do
    field :amount, :integer, null: false
    field :memo, :string, null: false
    field :status, AdjustmentStatus, null: false, default: :pending
    field :admin_id, :binary_id
    field :original_ledger_id, :binary_id, null: false
    field :adjust_ledger_id, :binary_id

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(adjustment, attrs) do
    adjustment
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> EctoEnum.validate_enum(:status)
  end

  @doc false
  def update_changeset(adjustment, attrs) do
    adjustment
    |> cast(attrs, [:status, :admin_id, :adjust_ledger_id])
    |> validate_required([:status, :admin_id])
    |> EctoEnum.validate_enum(:status)
  end
end
