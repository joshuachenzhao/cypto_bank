defmodule CyptoBankWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CyptoBankWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(CyptoBankWeb.ErrorView, :"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> render(CyptoBankWeb.ErrorView, :"401")
  end

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(CyptoBankWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, message}) when is_bitstring(message) or is_atom(message) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"error" => message})
  end

  def call(conn, {:error, error_step, {error_type, message}, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"error" => %{"transaction_error" => %{error_step => %{error_type => message}}}})
  end

  def call(conn, {:error, error_step, message, _}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"error" => %{"transaction_error" => %{error_step => message}}})
  end
end
