defmodule CyptoBankWeb.ErrorViewTest do
  use CyptoBankWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 401.json" do
    assert render(CyptoBankWeb.ErrorView, "401.json", []) == %{errors: %{detail: "Unauthorized"}}
  end

  test "renders 404.json" do
    assert render(CyptoBankWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert render(CyptoBankWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
