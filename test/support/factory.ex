defmodule CyptoBank.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: CyptoBank.Repo

  alias CyptoBank.Accounts.{Account, User}
  alias CyptoBank.Adjustments.Adjustment
  alias CyptoBank.Transactions.Ledger

  def user_factory do
    %User{
      email: sequence(:email, &"b-email-#{&1}@example.com"),
      is_admin: false,
      password: "some password"
    }
  end

  def admin_factory do
    %User{
      email: sequence(:email, &"a-email-#{&1}@example.com"),
      is_admin: true,
      password: "some password"
    }
  end

  def account_factory do
    %Account{
      balance: 10_000,
      user: build(:user)
    }
  end

  def ledger_factory do
    %Ledger{
      amount: 1_000,
      memo: "some memo",
      type: :deposit,
      account: build(:account)
    }
  end

  def adjustment_factory do
    %Adjustment{
      amount: 1_000,
      user: build(:user),
      memo: "some memo",
      status: :pending,
      original_ledger: build(:ledger),
      adjust_ledger: build(:ledger)
    }
  end
end
