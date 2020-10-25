defmodule CyptoBankWeb.Router do
  use CyptoBankWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :api_auth do
    plug :ensure_authenticated
  end

  scope "/api", CyptoBankWeb do
    pipe_through :api
    post "/users/sign_in", UserController, :sign_in
    post "/users/sign_up", UserController, :create
  end

  scope "/api", CyptoBankWeb do
    pipe_through [:api, :api_auth]

    get("/users", UserController, :index)
    get("/current_user", UserController, :show_current_user)
    get("/current_user/accounts", AccountController, :index)

    post("/current_user/accounts", AccountController, :create)

    get("/current_user/accounts/:account_id", AccountController, :show)
    get("/current_user/accounts/:account_id/transactions", TransactionController, :index)

    post "/current_user/accounts/:account_id/adjustments", AdjustmentController, :create

    post "/current_user/accounts/:account_id/adjustments/:adjustment_id",
         AdjustmentController,
         :show

    get(
      "/current_user/accounts/:account_id/transactions/:transaction_id",
      TransactionController,
      :show
    )

    post("/transactions/deposit", TransactionController, :deposit)
    post("/transactions/withdrawal", TransactionController, :withdrawal)
    post("/transactions/transfer", TransactionController, :transfer)

    # DOING
    get "/admin/adjustments", AdjustmentController, :index
    get "/admin/adjustments/:adjustment_id", AdjustmentController, :show
    put "/admin/adjustments/:adjustment_id", AdjustmentController, :approve

    # TODO
    # resources "/admins", AdminController
    # resources "/adjustments", AdjustmentController
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: CyptoBankWeb.Telemetry
    end
  end

  # Plug function
  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)

    if current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(CyptoBankWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user")
      |> halt()
    end
  end
end
