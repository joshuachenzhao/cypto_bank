defmodule CyptoBankWeb.TransactionController do
  use CyptoBankWeb, :controller

  alias CyptoBank.Accounts
  alias CyptoBank.Transactions
  alias CyptoBank.Transactions.Ledger

  alias CyptoBankWeb.Helpers

  action_fallback CyptoBankWeb.FallbackController

  # TODO
  # 1. index for admin to show all transactions
  # 2. index for client to show all transactions belongs to
  def index(conn, _params) do
    ledgers = Transactions.list_ledgers()
    render(conn, "index.json", ledgers: ledgers)
  end

  # TODO
  # create transaction for an account
  # amount, type, *memo
  # 1. deposit and withdraw only involve self account
  # 2. transfer involves self account and target account, use ecto Ledger

  @doc """
  create deposit and withdraw transaction for self account
  """
  # TODO amount should be decimal at param entry
  def deposit(conn, %{
        "transaction" =>
          %{"account_id" => account_id, "amount" => amount, "type" => "deposit"} =
            transaction_params
      })
      when is_integer(amount) and amount > 0 do
    # TODO refactor this to {:ok, foo}
    user_id = Helpers.current_user_id(conn)

    # TODO this needs transactional to Accounts balance update
    with {:ok, _account} <- Accounts.get_account_for_user!(user_id, account_id),
         {:ok, %Ledger{} = transaction} <-
           Transactions.create_ledger(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  @doc """
  create deposit and withdraw transaction for self account
  """
  def withdrawal(conn, %{
        "transaction" =>
          %{"account_id" => account_id, "amount" => amount, "type" => "withdrawal"} =
            transaction_params
      })
      when is_integer(amount) and amount > 0 do
    # transaction_params = transaction_params |> Map.put("type", :withdrawal)

    # TODO refactor this to {:ok, foo}
    user_id = Helpers.current_user_id(conn)

    # TODO this needs transactional to Accounts balance update
    with {:ok, _account} <- Accounts.get_account_for_user!(user_id, account_id),
         {:ok, %Ledger{} = transaction} <-
           Transactions.create_ledger(transaction_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def check_deposit_amount(amount) when is_integer(amount) and amount > 0, do: {:ok, amount}
  def check_deposit_amount(_amount), do: {:error, "Deposit amount must a positive integer"}
  def check_withdraw_amount(amount) when is_integer(amount) and amount > 0, do: {:ok, amount}
  def check_deposit_amount(_amount), do: {:error, "Deposit amount must a positive integer"}

  def create(conn, %{"transaction" => ledger_params}) do
    # %{"account_id" => account_id, "amount" => amount, "memo" => memo} = transaction_params
    #
    # user_id = Helpers.current_user_id(conn)
    #
    # Accounts.get_account_for_user!(user_id, account_id)

    with {:ok, %Ledger{} = transaction} <-
           Transactions.create_ledger(ledger_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.transaction_path(conn, :show, transaction))
      |> render("show.json", transaction: transaction)
    end
  end

  def show(conn, %{"id" => id}) do
    transaction = Transactions.get_ledger!(!id)
    render(conn, "show.json", transaction: transaction)
  end

  def update(conn, %{"id" => id, "transaction" => transaction_params}) do
    transaction = Transactions.get_ledger!(!id)

    with {:ok, %Ledger{} = transaction} <-
           Transactions.update_ledger(transaction, transaction_params) do
      render(conn, "show.json", transaction: transaction)
    end
  end

  def delete(conn, %{"id" => id}) do
    transaction = Transactions.get_ledger!(!id)

    with {:ok, %Ledger{}} <- Transactions.delete_ledger(transaction) do
      send_resp(conn, :no_content, "")
    end
  end
end
