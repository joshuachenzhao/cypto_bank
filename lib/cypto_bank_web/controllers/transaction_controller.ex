defmodule CyptoBankWeb.TransactionController do
  use CyptoBankWeb, :controller
  import CyptoBankWeb.Helpers, only: [verify_admin_access: 1, verify_account_access: 2]

  alias CyptoBank.Transactions

  action_fallback CyptoBankWeb.FallbackController

  # NOTE current admin has the access to make transaction on behalf ANY account,
  # which is security issue, but given the limited time for this code challenge,
  # I might revisit when time is allowed, best has two admins verification in
  # process for any admin actions.

  @doc """
  View transaction history for admin/operation team
  """
  def index_for_admin(conn, _params) do
    with {:ok, _user} <- verify_admin_access(conn) do
      ledgers = Transactions.list_ledgers()
      render(conn, "index.json", ledgers: ledgers)
    end
  end

  @doc """
  View transaction history for given account
  """
  def index_for_account(conn, %{"account_id" => account_id}) do
    with {:ok, _account} <- verify_account_access(conn, account_id) do
      ledgers = Transactions.list_ledgers_for_account(account_id)
      render(conn, "index.json", ledgers: ledgers)
    end
  end

  @doc """
  create deposit and withdraw transaction for self account
  """
  def deposit(conn, %{
        "account_id" => account_id,
        "transaction" => %{"amount" => amount}
      })
      when is_integer(amount) and amount > 0 do
    with {:ok, _account} <- verify_account_access(conn, account_id),
         {:ok, %{create_deposit_ledger_step: transaction}} <-
           Transactions.deposite(amount, account_id) do
      conn |> do_render("show.json", transaction: transaction)
    end
  end

  @doc """
  Deposit and withdrawal transaction for self account
  """
  def withdrawal(conn, %{
        "account_id" => account_id,
        "transaction" => %{"amount" => amount}
      })
      when is_integer(amount) and amount > 0 do
    with {:ok, _account} <- verify_account_access(conn, account_id),
         {:ok, %{create_withdrawal_ledger_step: transaction}} <-
           Transactions.withdrawal(amount, account_id) do
      conn |> do_render("show.json", transaction: transaction)
    end
  end

  @doc """
  Transfer function between accounts
  """
  def transfer(conn, %{
        "account_id" => account_id,
        "transaction" => %{
          "amount" => amount,
          "receive_account_id" => receive_account_id
        }
      })
      when is_integer(amount) and amount > 0 do
    with {:ok, _account} <- verify_account_access(conn, account_id),
         {:ok,
          %{
            create_send_ledger_step: send_transaction,
            create_receive_ledger_step: receive_transaction
          }} <-
           Transactions.transfer(amount, account_id, receive_account_id) do
      conn
      |> do_render(
        "transfer.json",
        send_transaction: send_transaction,
        receive_transaction: receive_transaction
      )
    end
  end

  @doc """
  View a single transaction by given transaction_id for an account
  """
  def show(conn, %{"account_id" => account_id, "transaction_id" => transaction_id}) do
    with {:ok, _account} <- verify_account_access(conn, account_id) do
      transaction = Transactions.get_ledger_for_account!(transaction_id, account_id)
      render(conn, "show.json", transaction: transaction)
    end
  end

  # Helper fn to handle render for transactions
  defp do_render(conn, view_template, params) do
    conn
    |> put_status(:created)
    |> render(view_template, params)
  end
end
