defmodule CyptoBankWeb.UserController do
  use CyptoBankWeb, :controller
  import CyptoBankWeb.Helpers, only: [fetch_current_user: 1, verify_admin_access: 1]

  alias CyptoBank.Accounts
  alias CyptoBank.Accounts.User
  alias CyptoBankWeb.{UserView, ErrorView}

  action_fallback CyptoBankWeb.FallbackController

  @doc """
  Index view of all users for admin/operation team
  """
  def index(conn, _params) do
    with {:ok, _user} <- verify_admin_access(conn) do
      users = Accounts.list_users()
      render(conn, "index.json", users: users)
    end
  end

  @doc """
  Create an user
  User then can create multiple account through:
  POST "/api/current_user/accounts"
  """
  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  @doc """
  Show current sign in user
  """
  def show_current_user(conn, _params) do
    with {:ok, %User{} = user} <- fetch_current_user(conn) do
      render(conn, "show.json", user: user)
    end
  end

  @doc """
  Show a user with given id for admin/operation
  """
  def show(conn, %{"user_id" => id}) do
    with {:ok, _user} <- verify_admin_access(conn) do
      user = Accounts.get_user!(id)
      render(conn, "show.json", user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  @doc """
  Sign in a user, with session renew, in this code challenge user authentication uses session based strategy for the sake of simplicity, for more time, JWT/OAuth or other token based strategies may be more suitable
  """
  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:current_user_id, user.id)
        |> configure_session(renew: true)
        |> put_status(:ok)
        |> put_view(UserView)
        |> render("sign_in.json", user: user)

      {:error, message} ->
        conn
        |> delete_session(:current_user_id)
        |> put_status(:unauthorized)
        |> put_view(ErrorView)
        |> render("401.json", message: message)
    end
  end
end
