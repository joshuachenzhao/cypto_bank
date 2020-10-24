defmodule CyptoBankWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use CyptoBankWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
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

  # def call(conn, {:error, %Ecto.Changeset{}}) do
  #   conn
  #   |> put_status(:unprocessable_entity)
  #   |> put_view(CyptoBankWeb.ErrorView)
  #   |> render(:"422")
  # end

  def call(conn, {:error, message}) when is_bitstring(message) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{"error" => message})
  end
end
