defmodule CyptoBank.AccountsTest do
  use CyptoBank.DataCase

  import CyptoBank.Factory

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.{Account, User}

  describe "users" do
    @valid_attrs %{email: "mail@email.com", password: "password"}

    test "get_user!/1 returns the user with given id" do
      user = insert(:user) |> user_no_password()
      assert Accounts.get_user!(user.id) == user
    end

    test "list_users/0 returns all users" do
      users = insert_list(3, :user) |> Enum.map(&user_no_password/1)
      assert Accounts.list_users() == users
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "mail@email.com"
      assert user.is_admin == false
      assert Bcrypt.verify_pass("password", user.password_hash)
    end

    test "authenticate_user/2 authenticates the user" do
      {:ok, user} = Accounts.create_user(%{email: "email@email.com", password: "password"})

      assert {:ok, authenticated_user} = Accounts.authenticate_user("email@email.com", "password")
      assert user |> user_no_password == authenticated_user
    end

    test "authenticate_user/2 fails with wrong email or password" do
      user = insert(:user)
      user_no_password = insert(:user) |> user_no_password()

      assert {:error, "Wrong email or password"} = Accounts.authenticate_user("wrong email", "")

      assert {:error, "Wrong email or password"} =
               Accounts.authenticate_user("", "wrong password")

      assert {:error, "Wrong email or password"} = Accounts.authenticate_user("", "")
    end
  end

  describe "accounts" do
    test "create_account_for_user/2 creates an account for user_id" do
      user = insert(:user)

      assert {:ok, %Account{} = account} = Accounts.create_account_for_user(user.id)
      assert account.balance == 0
      assert account.user_id == user.id
    end

    test "list_accounts_for_user/1 list all acounts for admin" do
      admin = insert(:admin)
      accounts = insert_list(5, :account)

      assert accounts = Accounts.list_accounts_for_user(admin)
    end

    test "list_accounts_for_user/1 list all acounts belongs to a user" do
      user = insert(:user)
      owned_accounts = insert_list(5, :account, user: user)
      no_owned_accounts = insert_list(5, :account)

      assert owned_accounts_accounts = Accounts.list_accounts_for_user(user)
      assert 5 == Accounts.list_accounts_for_user(user) |> length
    end

    test "fetch_account_for_user/2 fetch an acount for admin" do
      admin = insert(:admin)
      user = insert(:user)
      account = insert(:account, user: user)

      assert {:ok, accounts} = Accounts.fetch_account_for_user(admin, account.id)
    end

    test "fetch_account_for_user/2 fetch an acount belongs to a user with given id" do
      user = insert(:user)
      account = insert(:account, user: user)

      assert {:ok, accounts} = Accounts.fetch_account_for_user(user, account.id)
    end

    test "fetch_account_for_user/2 does not fetch an acount with given id that does not belong to a user" do
      user = insert(:user)
      another_user = insert(:user, email: "unique@email.com")
      account = insert(:account, user: another_user)

      assert {:error, :not_found} = Accounts.fetch_account_for_user(user, account.id)
    end
  end
end
