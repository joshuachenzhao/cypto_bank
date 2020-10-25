defmodule CyptoBank.Transactions.Ledger do
  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.Account
  alias CyptoBank.Adjustments.Adjustment

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @permitted_attrs ~w(
    amount
    memo
    type
    account_id
  )a
  @required_attrs ~w(
    amount
    type
    account_id
  )a

  defenum(LedgerType, :ledger_type, [
    :deposit,
    :withdrawal,
    :transfer_pay,
    :transfer_receive,
    :adjustment
  ])

  schema "ledgers" do
    field :amount, :integer, null: false
    field :memo, :string
    field :type, LedgerType, null: false

    belongs_to(:account, Account)

    has_many(:on_going_adjustments, Adjustment, foreign_key: :original_ledger_id)
    has_many(:finished_adjustments, Adjustment, foreign_key: :adjust_ledger_id)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(ledger, attrs) do
    ledger
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> EctoEnum.validate_enum(:type)
    |> sanitize_amount()
    |> check_credit_limit()
    |> format_double_entry_amount()
    |> foreign_key_constraint(:account_id)
  end

  # absolute amount to avoid negative amount input, except for adjustment type, which in the future, should seperate into dr and cr adjustment
  defp sanitize_amount(%Ecto.Changeset{valid?: true, changes: %{type: :adjustment}} = changeset),
    do: changeset

  defp sanitize_amount(%Ecto.Changeset{valid?: true, changes: %{amount: amount}} = changeset) do
    put_change(changeset, :amount, abs(amount))
  end

  defp sanitize_amount(changeset), do: changeset

  defp check_credit_limit(
         %Ecto.Changeset{
           valid?: true,
           changes: %{type: type, amount: amount, account_id: account_id}
         } = changeset
       )
       when type == :withdrawal or type == :transfer_pay do
    with {:ok, _amount} <- do_check_withdraw_limit(amount, account_id) do
      changeset
    else
      {:error, error} ->
        add_error(changeset, :error, error)
    end
  end

  defp check_credit_limit(changeset), do: changeset

  defp do_check_withdraw_limit(amount, account_id) do
    %Account{balance: balance} = Accounts.get_account!(account_id)

    if amount <= balance,
      do: {:ok, amount},
      else:
        {:error,
         "Current balance: #{balance}, not sufficient for withdraw or transfer of $#{amount}"}
  end

  defp format_double_entry_amount(
         %Ecto.Changeset{
           valid?: true,
           changes: %{type: type, amount: amount}
         } = changeset
       )
       when type == :withdrawal or type == :transfer_pay do
    put_change(changeset, :amount, cr_ledger_entry(amount))
  end

  defp format_double_entry_amount(changeset), do: changeset

  defp cr_ledger_entry(amount), do: -amount
end
