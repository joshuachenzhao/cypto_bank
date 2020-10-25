defmodule CyptoBankWeb.AdjustmentView do
  use CyptoBankWeb, :view
  alias CyptoBankWeb.AdjustmentView

  def render("index.json", %{adjustments: adjustments}) do
    %{data: render_many(adjustments, AdjustmentView, "adjustment.json")}
  end

  def render("show.json", %{adjustment: adjustment}) do
    %{data: render_one(adjustment, AdjustmentView, "adjustment.json")}
  end

  def render("adjustment.json", %{adjustment: adjustment}) do
    %{id: adjustment.id}
  end
end
