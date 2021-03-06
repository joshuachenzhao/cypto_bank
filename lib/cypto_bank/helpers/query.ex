defmodule CyptoBank.Helpers.Query do
  @moduledoc """
  Query related helper functions module
  """
  import Ecto.Query, warn: false

  alias CyptoBank.Accounts.Account

  @doc """
  preloads fields
  """
  def preloads(Account), do: [:user]

  @doc """
  preloaded query
  """
  def query_preload(query) do
    from(
      x in query,
      preload: ^preloads(query)
    )
  end

  @doc """
  return query with assoc_field.id = assoc_id
  prerequisite: where x and y has association relationship
  """
  def query_join(query, association, field, value) do
    from(
      x in query,
      join: y in assoc(x, ^association),
      where: field(y, ^field) == ^value
    )
  end

  @doc """
  select query by query.field == value
  """
  def query_select(query, field) do
    from(
      x in query,
      select: field(x, ^field)
    )
  end

  @doc """
  select query by query.field == value
  def foo(query, field, value) do
    query
    |> where(field: ^value)
  end
  """
  def query_select(query, field, value) do
    from(
      x in query,
      select: x,
      where: field(x, ^field) == ^value
    )
  end

  def query_select(query, field, value, :==) do
    from(
      x in query,
      select: x,
      where: field(x, ^field) == ^value
    )
  end

  def query_select(query, field, value, :>) do
    from(
      x in query,
      select: x,
      where: field(x, ^field) > ^value
    )
  end

  def query_select(query, field, value, :<) do
    from(
      x in query,
      select: x,
      where: field(x, ^field) < ^value
    )
  end

  def query_select(query, select_field, conditional_field, value, :<) do
    from(
      x in query,
      select: field(x, ^select_field),
      where: field(x, ^conditional_field) < ^value
    )
  end

  @doc """
  get or update
  """
  def get_or_update(repo, schema, field, field_value, params) do
    options =
      Keyword.new()
      |> Keyword.put(field, field_value)

    case repo.get_by(schema, options) do
      nil ->
        schema.__struct__
        |> schema.changeset(params)
        |> repo.insert()

      x ->
        x
        |> schema.changeset(params)
        |> repo.update()
    end
  end
end
