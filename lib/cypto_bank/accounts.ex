defmodule CyptoBank.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import CyptoBank.Helpers.Query

  alias CyptoBank.Repo
  alias CyptoBank.Accounts.Account
  alias CyptoBank.Accounts.User

  @doc """
  create account for user
  """
  def create_account_for_user(user_id, attrs \\ %{}) do
    attrs = Map.put(attrs, "user_id", user_id)

    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def list_accounts_for_user(user_id) do
    Account
    |> query_join(:user, :id, user_id)
    |> Repo.all()
  end

  def get_account_for_user!(user_id, account_id) do
    Account
    |> query_join(:user, :id, user_id)
    |> Repo.fetch(account_id)
  end

  def get_account!(id), do: Repo.get!(Account, id)

  # TODO need to break the context
  # --------------------------------------------------

  def list_users do
    Repo.all(User)
  end

  def fetch_user(id), do: Repo.fetch(User, id)
  def get_user(id), do: Repo.get(User, id)
  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def authenticate_user(email, password) do
    query = from(u in User, where: u.email == ^email)
    query |> Repo.one() |> verify_password(password)
  end

  defp verify_password(nil, _) do
    # Perform a dummy check to make user enumeration more difficult
    Bcrypt.no_user_verify()
    {:error, "Wrong email or password"}
  end

  defp verify_password(user, password) do
    if Bcrypt.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, "Wrong email or password"}
    end
  end
end
