defmodule CyptoBankWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CyptoBankWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> render(CyptoBankWeb.ErrorView, :"401")
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(CyptoBankWeb.ErrorView, :"404")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(CyptoBankWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, error_step, {error_type, error}, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(CyptoBankWeb.ErrorView, "error.json",
      message: %{:error_step => error_step, :error_type => error_type, :error => error}
    )
  end

  def call(conn, {:error, error_step, error, _}) do
    conn
    |> put_status(:unprocessable_entity)
    # |> render(CyptoBankWeb.ErrorView, "error.json",
    |> render(CyptoBankWeb.ErrorView, "error.json",
      message: %{:error_step => error_step, :error => error}
    )
  end

  def call(conn, {:error, error}) when is_bitstring(error) or is_atom(error) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(CyptoBankWeb.ErrorView, "error.json", message: error)
  end
end
