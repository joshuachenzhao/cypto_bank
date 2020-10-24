defmodule CyptoBankWeb.TransactionView do
  use CyptoBankWeb, :view
  alias CyptoBankWeb.TransactionView

  def render("index.json", %{ledgers: ledgers}) do
    %{data: render_many(ledgers, TransactionView, "transaction.json")}
  end

  def render("show.json", %{transaction: transaction}) do
    %{data: render_one(transaction, TransactionView, "transaction.json")}
  end

  def render("transfer.json", %{
        send_transaction: send_transaction,
        receive_transaction: receive_transaction
      }) do
    %{
      data:
        render_many([send_transaction, receive_transaction], TransactionView, "transaction.json")
    }
  end

  def render("transaction.json", %{transaction: transaction}) do
    %{
      transaction: %{
        id: transaction.id,
        type: transaction.type,
        amount: transaction.amount,
        memo: transaction.memo,
        inserted_at: transaction.inserted_at,
        updated_at: transaction.updated_at
      }
    }
  end
end
