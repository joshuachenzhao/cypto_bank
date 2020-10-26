defmodule CyptoBank.Accounts.Account do
  @moduledoc """
  Account schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias CyptoBank.Accounts.User
  alias CyptoBank.Transactions.Ledger

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_attrs ~w(balance user_id)a

  schema "accounts" do
    field :balance, :integer, default: 0

    belongs_to(:user, User)
    has_many(:ledgers, Ledger)
    has_many :adjustments, through: [:ledgers, :adjustments]

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:user_id)
    |> check_balance()
  end

  defp check_balance(
         %Ecto.Changeset{
           valid?: true,
           changes: %{balance: balance}
         } = changeset
       ) do
    if balance >= 0,
      do: changeset,
      else: add_error(changeset, :error, "Balance can not be less than 0")
  end

  defp check_balance(changeset), do: changeset
end
