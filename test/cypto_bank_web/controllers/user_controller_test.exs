defmodule CyptoBankWeb.UserControllerTest do
  use CyptoBankWeb.ConnCase

  alias CyptoBank.Accounts
  alias Plug.Test

  @admin_create_attrs %{
    email: "admin@email.com",
    is_admin: true,
    password: "some password"
  }
  @create_attrs %{
    email: "user@email.com",
    is_admin: false,
    password: "some password"
  }
  @invalid_attrs %{email: nil, is_admin: nil, password: nil}
  @current_user_attrs %{
    email: "some current user email",
    is_admin: false,
    password: "some current user password"
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  def fixture(:admin) do
    {:ok, admin} = Accounts.create_user(@admin_create_attrs)
    admin
  end

  def fixture(:current_user) do
    {:ok, current_user} = Accounts.create_user(@current_user_attrs)
    current_user
  end

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user_admin(conn)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), current_user: current_user}
  end

  describe "index" do
    test "lists all users for admin/operation", %{conn: conn, current_user: current_user} do
      conn = get(conn, Routes.user_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "user" => %{
                   "id" => current_user.id,
                   "email" => current_user.email,
                   "is_admin" => current_user.is_admin,
                   "inserted_at" => current_user.inserted_at |> DateTime.to_iso8601(),
                   "updated_at" => current_user.updated_at |> DateTime.to_iso8601()
                 }
               }
             ]
    end

    # test "lists all users for admin/operation return error if user does not have admin access", %{
    #   conn: conn,
    #   current_user: current_user
    # } do
    #   conn = get(conn, Routes.user_path(conn, :index))
    #
    #   assert json_response(conn, 422) == %{"errors" => %{"detail" => "no_admin_access"}}
    # end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{
               "user" => %{
                 "id" => id,
                 "email" => _email,
                 "is_admin" => _is_admin,
                 "inserted_at" => _inserted_at,
                 "updated_at" => _updated_at
               }
             } = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "user" => %{
                 "id" => _id,
                 "email" => _email,
                 "is_admin" => _is_admin,
                 "inserted_at" => _inserted_at,
                 "updated_at" => _updated_at
               }
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "sign in user" do
    test "returns the user with good credentials", %{conn: conn, current_user: current_user} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            email: current_user.email,
            password: current_user.password
          })
        )

      assert json_response(conn, 200)["data"] == %{
               "user" => %{
                 "id" => current_user.id,
                 "email" => current_user.email,
                 "is_admin" => current_user.is_admin,
                 "inserted_at" => current_user.inserted_at |> DateTime.to_iso8601(),
                 "updated_at" => current_user.updated_at |> DateTime.to_iso8601()
               }
             }
    end

    test "returns errors with bad credentials", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :sign_in, %{
            email: "non-existent email",
            password: ""
          })
        )

      assert json_response(conn, 401)["errors"] == %{
               "detail" => "Wrong email or password"
             }
    end
  end

  def setup_current_user(conn) do
    current_user = fixture(:current_user)

    {:ok,
     conn: Test.init_test_session(conn, current_user_id: current_user.id),
     current_user: current_user}
  end

  def setup_current_user_admin(conn) do
    current_user = fixture(:admin)

    {:ok,
     conn: Test.init_test_session(conn, current_user_id: current_user.id),
     current_user: current_user}
  end
end
