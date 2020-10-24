defmodule CyptoBankWeb.Helpers do
  import Plug.Conn

  alias CyptoBank.Accounts

  def current_user_id(conn) do
    conn |> get_session(:current_user_id)
  end

  def current_user(conn) do
    conn
    |> current_user_id()
    |> Accounts.get_user!()
  end
end
