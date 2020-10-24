defmodule CyptoBank.Repo do
  use Ecto.Repo,
    otp_app: :cypto_bank,
    adapter: Ecto.Adapters.Postgres

  @doc """
  to handle UUID Ecto.Query.CastError :error, return tuple
  """
  def fetch(query, id, opts \\ []) do
    case get(query, id, opts) do
      nil -> {:error, :not_found}
      schema -> {:ok, schema}
    end
  end

  @doc """
  to handle UUID Ecto.Query.CastError :error
  """
  defoverridable get: 2, get: 3

  def get(query, id, opts \\ []) do
    super(query, id, opts)
  rescue
    Ecto.Query.CastError -> nil
  end
end
