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

  def send_account_factory do
    %Account{
      balance: 30_000,
      user: build(:user)
    }
  end

  def receive_account_factory do
    %Account{
      balance: 10_000,
      user: build(:user)
    }
  end

  def ledger_factory do
    %Ledger{
      amount: 10_000,
      memo: "some memo",
      type: :deposit,
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
      amount: 1_000,
      user: build(:user),
      memo: "some memo",
      status: :pending,
      original_ledger: build(:deposit_ledger),
      adjust_ledger: nil,
      admin_id: nil
    }
  end
end
