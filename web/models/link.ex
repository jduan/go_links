defmodule GoLinks.Link do
  require Logger
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
    |> validate_change(:url, fn
      :url, url ->
        if valid_url?(url) do
          Logger.debug "url is valid"
          []
        else
          Logger.debug "url is invalid"
          [url: "url #{url} is invalid2"]
        end
    end)
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
