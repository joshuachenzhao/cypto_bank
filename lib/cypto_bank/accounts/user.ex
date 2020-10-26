defmodule CyptoBank.Accounts.User do
  @moduledoc """
  User schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias CyptoBank.Accounts.Account
  alias CyptoBank.Adjustments.Adjustment

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_attrs ~w(
      email
      is_admin
      password
    )a

  schema "users" do
    field :email, :string
    field :is_admin, :boolean, default: false
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many(:adjustments, Adjustment, foreign_key: :admin_id)
    has_many(:accounts, Account)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> put_password_hash
    |> unique_constraint(:email, message: "There is already a user with this email")
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ),
       do: change(changeset, Bcrypt.add_hash(password))

  defp put_password_hash(%Ecto.Changeset{} = changeset), do: changeset
end
