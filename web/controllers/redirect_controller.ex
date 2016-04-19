defmodule GoLinks.RedirectController do
  require Logger
  use GoLinks.Web, :controller

  @placeholder "%s"

  alias GoLinks.Link

  def handle_redirect(conn, %{"path" => path} = params) do
    IO.puts "params: #{inspect params}"
    [name | placeholders] = path
    IO.puts "redirect name: #{name}"
    IO.puts "redirect placeholders: #{inspect placeholders}"
    link = lookup_link(name)
    case find_redirect_link(name, link, placeholders) do
      {:ok, redirect_link} ->
        Logger.debug "redirect to url: #{redirect_link}"
        increment_visited(link)
        redirect conn, external: redirect_link
      {:not_found} -> not_found(conn)
      {:bad_request, reason} ->
        bad_request(conn, reason)
    end
  end

  defp find_redirect_link(name, nil, []) do
    Logger.debug "No golinks for name: #{name}"
    {:not_found}
  end

  @doc """
  This is a simple redirect for just a name without additional placerholders.
  """
  defp find_redirect_link(name, link, []) do
    Logger.debug "Simple redirect #{name} without query strings"

    if link do
      {:ok, link.url}
    else
      {:not_found}
    end
  end

  @doc """
  This is a redirect for a name with additional placerholders.
  For example, for a request like "http://go/chill/1234/pretty",
  * "name" would be "chill"
  * "args" would be ["1234", "pretty"]
  """
  defp find_redirect_link(name, link, args) do
    Logger.debug "redirect #{name} with query strings: #{inspect args}"

    if link do
      query_url = link.query_url
      if query_url do
        case fill_query_url(query_url, args) do
          {filled_url, :ok} ->
            {:ok, filled_url}
          {_filled_url, :error} ->
            {:bad_request, "Bad request: you didn't provide enough query strings"}
        end
      else
        {:bad_request, "Bad request: this 'go link' doesn't support query strings"}
      end
    else
      {:not_found}
    end
  end

  defp bad_request(conn, message) do
    conn
    |> put_status(:bad_request)
    |> render(GoLinks.ErrorView, "400.html", message: message)
  end

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(GoLinks.ErrorView, "404.html")
  end

  defp lookup_link(name) do
    Repo.get_by(Link, name: name)
  end

  @doc """
  Given a query_url like "https://jira.fitbit.com/browse/IPD-%s/what/%s",
  fill the placeholders (%s) with the args.
  """
  defp fill_query_url(query_url, []) do
    if String.contains?(query_url, @placeholder) do
      {query_url, :error}
    else
      {query_url, :ok}
    end
  end

  defp fill_query_url(query_url, [head | rest]) do
    if String.contains?(query_url, @placeholder) do
      replaced = String.replace(query_url, @placeholder, head, global: false)
      fill_query_url(replaced, rest)
    else
      {query_url, :ok}
    end
  end

  defp increment_visited(link) do
    visited = case link.visited do
      nil -> 1
      n -> n + 1
    end
    link = Ecto.Changeset.change link, visited: visited
    case Repo.update link do
      {:ok, _model} -> Logger.debug "Successfully incremented the visited column"
      {:error, changeset} -> Logger.debug "Failed to increment the visited column: #{inspect changeset}"
    end
  end
end
