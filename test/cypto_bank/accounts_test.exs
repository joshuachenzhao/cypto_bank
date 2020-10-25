defmodule CyptoBank.AccountsTest do
  use CyptoBank.DataCase

  alias CyptoBank.Accounts

  describe "users" do
    alias CyptoBank.Accounts.User

    @valid_attrs %{email: "some email", is_admin: true, password: "some password"}
    @update_attrs %{
      email: "some updated email",
      is_admin: true,
      password: "some updated password"
    }
    @invalid_attrs %{email: nil, is_admin: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    def user_without_password(attrs \\ %{}) do
      %{user_fixture(attrs) | password: nil}
    end

    test "list_users/0 returns all users" do
      user = user_without_password()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_without_password()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.is_admin == false
      assert Bcrypt.verify_pass("some password", user.password_hash)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "some updated email"
      assert user.is_admin == true
      assert Bcrypt.verify_pass("some updated password", user.password_hash)
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_without_password()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "authenticate_user/2 authenticates the user" do
      user = user_without_password()

      assert {:error, "Wrong email or password"} = Accounts.authenticate_user("wrong email", "")

      assert {:ok, authenticated_user} =
               Accounts.authenticate_user(user.email, @valid_attrs.password)

      assert user == authenticated_user
    end
  end
end
