defmodule CyptoBank.Seeds.Seed do
  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.{Account, User}
  alias CyptoBank.Adjustments
  alias CyptoBank.Adjustments.Adjustment
  alias CyptoBank.Transactions
  alias CyptoBank.Transactions.Ledger

  def generate() do
    # Add more seed fns here
    seed_admins
    seed_clients_with_trans()

    IO.puts("-----> Done: Seeding Complete!")
  end

  def seed_admins() do
    admin_param_lists
    |> Enum.each(&Accounts.create_user/1)
  end

  def seed_clients_with_trans() do
    user_param_lists_tuple(1..10)
    |> Enum.each(&client_pair_with_trans/1)
  end

  @doc """
  create a pair of client accounts
  each client account has one deposit, one withdraw, one transfer,
  one adjustment for deposit, one adjustment for withdrawal
  """
  def client_pair_with_trans({user_params_1, user_params_2}) do
    with {:ok, %{user_id: user_id_1, account_id: account_id_1}} <- create_account(user_params_1),
         {:ok, %{user_id: user_id_2, account_id: account_id_2}} <- create_account(user_params_2),
         {:ok, %{create_deposit_ledger_step: dep_tran_1}} <-
           Transactions.deposite(Enum.random(30..100) * 10000, account_id_1),
         {:ok, %{create_deposit_ledger_step: dep_tran_2}} <-
           Transactions.deposite(Enum.random(30..100) * 10000, account_id_2),
         {:ok, %{create_withdrawal_ledger_step: with_tran_1}} <-
           Transactions.withdrawal(Enum.random(1..50) * 1000, account_id_1),
         {:ok, %{create_withdrawal_ledger_step: with_tran_2}} <-
           Transactions.withdrawal(Enum.random(1..50) * 1000, account_id_2),
         {:ok,
          %{
            create_send_ledger_step: send_tran_1,
            create_receive_ledger_step: receive_tran_1
          }} <-
           Transactions.transfer(Enum.random(1..50) * 1000, account_id_1, account_id_2),
         {:ok,
          %{
            create_send_ledger_step: send_tran_2,
            create_receive_ledger_step: receive_tran_2
          }} <-
           Transactions.transfer(Enum.random(1..50) * 1000, account_id_2, account_id_1),
         {:ok, %Adjustment{} = dep_adj} <-
           Adjustments.create_adjustment(%{
             "original_ledger_id" => dep_tran_1.id,
             "amount" => Enum.random(1..20000) * 100
           }),
         {:ok, %Adjustment{} = with_adj} <-
           Adjustments.create_adjustment(%{
             "original_ledger_id" => with_tran_2.id,
             "amount" => Enum.random(1..20000) * 100
           }) do
      {:ok, "Successfully added a pair of clients with transactions and adjustments"}
    end
  end

  def create_account(user_param) do
    with {:ok, %User{id: user_id}} <- Accounts.create_user(user_param),
         {:ok, %Account{id: account_id}} <- Accounts.create_account_for_user(user_id) do
      {:ok, %{user_id: user_id, account_id: account_id}}
    end
  end

  defp admin_param_lists() do
    for a <- 0..5, do: %{email: "admin_#{a}@email.com", password: "qwerty", is_admin: true}
  end

  defp user_param_lists_tuple(range) do
    for a <- range,
        do:
          {%{email: "user_#{a}@email.com", password: "qwerty"},
           %{email: "user_#{a + 10}@email.com", password: "qwerty"}}
  end
end
