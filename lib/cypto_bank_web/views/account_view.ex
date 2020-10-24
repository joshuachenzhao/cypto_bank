defmodule CyptoBankWeb.AccountView do
  use CyptoBankWeb, :view
  alias CyptoBankWeb.AccountView

  def render("index.json", %{accounts: accounts}) do
    %{data: render_many(accounts, AccountView, "account.json")}
  end

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      account: %{
        id: account.id,
        balance: account.balance,
        user_id: account.user_id,
        inserted_at: account.inserted_at,
        updated_at: account.updated_at
      }
    }
  end
end
