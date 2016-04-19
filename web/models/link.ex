defmodule GoLinks.Link do
  require Logger
  use GoLinks.Web, :model

  schema "links" do
    field :name, :string
    field :url, :string
    field :query_url, :string
    field :visited, :integer, default: 0

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
    |> validate_change(:url, &url_validator/2)
    |> validate_change(:query_url, &url_validator/2)
  end

  defp url_validator(url, value) do
    if valid_url?(value) do
      Logger.debug "#{inspect url} #{value} is valid"
      []
    else
      Logger.debug "#{inspect url} #{value} is invalid"
      [{url, "#{Atom.to_string url} '#{value}' is invalid"}]
    end
  end

  defp valid_url?(url) do
    uri = URI.parse(url)
    Logger.debug "uri is #{inspect uri}"
    case uri do
      %URI{scheme: nil} -> false
      %URI{host: nil} -> false
      uri -> case uri do
        %URI{scheme: "http"} -> true
        %URI{scheme: "https"} -> true
        _ -> false
      end
    end
  end
end
