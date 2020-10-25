defmodule CyptoBank.Adjustments do
  @moduledoc """
  The Adjustments context.
  """

  import Ecto.Query, warn: false
  alias CyptoBank.Repo

  alias CyptoBank.Adjustments.Adjustment

  def list_adjustments do
    Repo.all(Adjustment)
  end

  def get_adjustment!(id), do: Repo.get!(Adjustment, id)

  def create_adjustment(attrs \\ %{}) do
    %Adjustment{}
    |> Adjustment.changeset(attrs)
    |> Repo.insert()
  end

  def update_adjustment(%Adjustment{} = adjustment, attrs) do
    adjustment
    |> Adjustment.changeset(attrs)
    |> Repo.update()
  end

  def delete_adjustment(%Adjustment{} = adjustment) do
    Repo.delete(adjustment)
  end

  def change_adjustment(%Adjustment{} = adjustment, attrs \\ %{}) do
    Adjustment.changeset(adjustment, attrs)
  end
end
