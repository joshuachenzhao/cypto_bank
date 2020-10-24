defmodule CyptoBank.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @required_attrs ~w(
      email
      is_active
      password
    )a

  schema "users" do
    field :email, :string
    field :is_active, :boolean, default: true
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> put_password_hash
    |> unique_constraint(:email)
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ),
       do: change(changeset, Bcrypt.add_hash(password))

  defp put_password_hash(%Ecto.Changeset{} = changeset), do: changeset
end
