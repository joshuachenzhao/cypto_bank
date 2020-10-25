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
    %{
      adjustment: %{
        id: adjustment.id,
        adjustment: adjustment.amount,
        status: adjustment.status,
        memo: adjustment.memo,
        admin_id: adjustment.admin_id,
        original_ledger_id: adjustment.original_ledger_id,
        adjust_ledger_id: adjustment.adjust_ledger_id,
        inserted_at: adjustment.inserted_at,
        updated_at: adjustment.updated_at
      }
    }
  end
end
