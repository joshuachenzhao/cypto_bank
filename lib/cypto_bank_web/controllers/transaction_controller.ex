defmodule CyptoBankWeb.TransactionController do
  use CyptoBankWeb, :controller
  import CyptoBankWeb.Helpers, only: [account_ownership_check: 2]

  alias CyptoBank.Transactions

  action_fallback CyptoBankWeb.FallbackController

  # TODO
  # 1. index for admin to show all transactions
  # 2. index for client to show all transactions belongs to
  # NOTE current admin has the access to make transaction on behalf ANY account,
  # which is security issue, but given the limited time for this code challenge,
  # I might revisit when time is allowed, best has two admins verification in
  # process for any admin actions.
  def index(conn, %{"account_id" => account_id}) do
    with {:ok, _account} <- account_ownership_check(conn, account_id) do
      ledgers = Transactions.list_ledgers_for_account(account_id)
      render(conn, "index.json", ledgers: ledgers)
    end
  end

  @doc """
  create deposit and withdraw transaction for self account
  """
  def deposit(conn, %{
        "transaction" => %{"account_id" => account_id, "amount" => amount, "type" => "deposit"}
      })
      when is_integer(amount) and amount > 0 do
    with {:ok, _account} <- account_ownership_check(conn, account_id),
         {:ok, %{create_deposit_ledger_step: transaction}} <-
           Transactions.deposite(amount, account_id) do
      conn |> do_render("show.json", [transaction: transaction], :deposit)
    end
  end

  @doc """
  Deposit and withdrawal transaction for self account
  """
  def withdrawal(conn, %{
        "transaction" => %{"account_id" => account_id, "amount" => amount, "type" => "withdrawal"}
      })
      when is_integer(amount) and amount > 0 do
    with {:ok, _account} <- account_ownership_check(conn, account_id),
         {:ok, %{create_withdrawal_ledger_step: transaction}} <-
           Transactions.withdrawal(amount, account_id) do
      conn |> do_render("show.json", [transaction: transaction], :withdrawal)
    end
  end

  @doc """
  Transfer function between accounts
  """
  def transfer(conn, %{
        "transaction" => %{
          "account_id" => account_id,
          "amount" => amount,
          "type" => "transfer_pay",
          "receive_account_id" => receive_account_id
        }
      })
      when is_integer(amount) and amount > 0 do
    with {:ok, _account} <- account_ownership_check(conn, account_id),
         {:ok,
          %{
            create_send_ledger_step: send_transaction,
            create_receive_ledger_step: receive_transaction
          }} <-
           Transactions.transfer(amount, account_id, receive_account_id) do
      conn
      |> do_render(
        "transfer.json",
        [
          send_transaction: send_transaction,
          receive_transaction: receive_transaction
        ],
        :transfer
      )
    end
  end

  def show(conn, %{"account_id" => account_id, "transaction_id" => transaction_id}) do
    with {:ok, _account} <- account_ownership_check(conn, account_id) do
      transaction = Transactions.get_ledger_for_account!(transaction_id, account_id)
      render(conn, "show.json", transaction: transaction)
    end
  end

  defp do_render(conn, view_template, params, controller_fn) do
    conn
    |> put_status(:created)
    |> put_resp_header("location", Routes.transaction_path(conn, controller_fn))
    |> render(view_template, params)
  end
end
