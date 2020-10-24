defmodule CyptoBank.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  alias CyptoBank.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_attrs ~w(balance user_id)a

  schema "accounts" do
    field :balance, :integer, default: 0

    belongs_to(:user, User)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
  end
end
