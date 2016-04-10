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
    do_redirect(conn, name, placeholders)
  end

  @doc """
  This is a simple redirect for just a name without additional placerholders.
  """
  defp do_redirect(conn, name, []) do
    Logger.debug "Simple redirect without query strings"
    link = lookup_link(name)

    if link do
      redirect conn, external: link.url
    else
      not_found(conn)
    end
  end

  @doc """
  This is a redirect for a name with additional placerholders.
  For example, for a request like "http://go/chill/1234/pretty",
  * "name" would be "chill"
  * "args" would be ["1234", "pretty"]
  """
  defp do_redirect(conn, name, args) do
    Logger.debug "redirect #{name} with query strings: #{inspect args}"
    link = lookup_link(name)

    if link do
      query_url = link.query_url
      if query_url do
        case fill_query_url(query_url, args) do
          {filled_url, :ok} ->
            Logger.debug "redirect to url: #{filled_url}"
            redirect conn, external: filled_url
          {_filled_url, :error} ->
            bad_request(conn, "Bad request: you didn't provide enough query strings")
        end
      else
        bad_request(conn, "Bad request: this 'go link' doesn't support query strings")
      end
    else
      not_found(conn)
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
end
