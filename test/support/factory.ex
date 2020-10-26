defmodule CyptoBank.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: CyptoBank.Repo

  alias CyptoBank.Accounts.{Account, User}
  alias CyptoBank.Adjustments.Adjustment
  alias CyptoBank.Transactions.Ledger

  def user_factory do
    %User{
      email: sequence(:email, &"test-email-#{&1}@example.com"),
      is_admin: false,
      password: "some password"
    }
  end

  def user_no_password(user) do
    %{user | password: nil}
  end

  def make_admin(user) do
    %{user | is_admin: true}
  end

  def admin_factory do
    %User{
      email: sequence(:email, &"admin-email-#{&1}@example.com"),
      is_admin: true,
      password: "some password"
    }
  end

  def account_factory do
    %Account{
      balance: 100_000,
      user: build(:user)
    }
  end

  def ledger_factory do
    %Ledger{
      amount: 10_000,
      memo: "some memo",
      account: build(:account)
    }
  end

  def deposit_ledger_factory do
    %Ledger{
      amount: 10_000,
      memo: "some memo",
      type: :deposit,
      account: build(:account)
    }
  end

  def withdrawal_ledger_factory do
    %Ledger{
      amount: -10_000,
      memo: "some memo",
      type: :withdrawal,
      account: build(:account)
    }
  end

  def tran_send_ledger_factory do
    %Ledger{
      amount: -10_000,
      memo: "some memo",
      type: :transfer_pay,
      account: build(:account)
    }
  end

  def tran_rec_ledger_factory do
    %Ledger{
      amount: 10_000,
      memo: "some memo",
      type: :transfer_receive,
      account: build(:account)
    }
  end

  def adj_deposit_ledger_factory do
    %Ledger{
      amount: 1_000,
      memo: "some memo",
      type: :adjustment,
      account: build(:account)
    }
  end

  def adj_withdrawal_ledger_factory do
    %Ledger{
      amount: -1_000,
      memo: "some memo",
      type: :adjustment,
      account: build(:account)
    }
  end

  def adjustment_factory do
    %Adjustment{
      amount: 10_000,
      admin: build(:admin),
      memo: "some memo",
      status: :pending,
      original_ledger: build(:ledger),
      adjust_ledger: nil
    }
  end

  def get_fields(maps, field) do
    maps |> Enum.map(&Map.get(&1, field))
  end
end
