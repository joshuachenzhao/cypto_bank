defmodule CyptoBank.Repo do
  use Ecto.Repo,
    otp_app: :cypto_bank,
    adapter: Ecto.Adapters.Postgres
end
