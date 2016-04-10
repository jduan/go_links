defmodule GoLinks.Link do
  use GoLinks.Web, :model

  schema "links" do
    field :name, :string
    field :url, :string
    field :query_url, :string

    timestamps
  end

  @required_fields ~w(name url)
  @optional_fields ~w(query_url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
