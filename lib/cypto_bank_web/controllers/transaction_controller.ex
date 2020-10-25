defmodule CyptoBankWeb.TransactionController do
  use CyptoBankWeb, :controller
  import CyptoBankWeb.Helpers, only: [fetch_current_user: 1]

  alias CyptoBank.Accounts
  alias CyptoBank.Transactions
  alias CyptoBank.Transactions.Ledger

  action_fallback CyptoBankWeb.FallbackController

  # TODO
  # 1. index for admin to show all transactions
  # 2. index for client to show all transactions belongs to
  def index(conn, %{"account_id" => account_id}) do
    with {:ok, _account} <- user_account_sercurity_check(conn, account_id) do
      ledgers = Transactions.list_ledgers_for_account(account_id)
      render(conn, "index.json", ledgers: ledgers)
    end
  end

  @doc """
  create deposit and withdraw transaction for self account
  """
  # TODO amount should be decimal at param entry
  def deposit(conn, %{
        "transaction" => %{"account_id" => account_id, "amount" => amount, "type" => "deposit"}
      })
      when is_integer(amount) and amount > 0 do
    with {:ok, _account} <- user_account_sercurity_check(conn, account_id),
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
    with {:ok, _account} <- user_account_sercurity_check(conn, account_id),
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
    with {:ok, _account} <- user_account_sercurity_check(conn, account_id),
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
    with {:ok, _account} <- user_account_sercurity_check(conn, account_id) do
      transaction = Transactions.get_ledger_for_account!(transaction_id, account_id)
      render(conn, "show.json", transaction: transaction)
    end
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Transactions.get_ledger!(!id)

    with {:ok, %Ledger{} = transaction} <-
           Transactions.update_ledger(transaction, transaction_params) do
      render(conn, "show.json", transaction: transaction)
    end
  end

  defp user_account_sercurity_check(conn, account_id) do
    with {:ok, user} <- fetch_current_user(conn) do
      Accounts.fetch_account_for_user(user, account_id)
    end
  end

  defp do_render(conn, view_template, params, controller_fn) do
    conn
    |> put_status(:created)
    |> put_resp_header("location", Routes.transaction_path(conn, controller_fn))
    |> render(view_template, params)
  end
end
