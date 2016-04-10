defmodule GoLinks.RedirectController do
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
    link = lookup_link(name)

    if link do
      redirect conn, external: link.url
    else
      conn
      |> put_status(:not_found)
      |> render(GoLinks.ErrorView, "404.html")
    end
  end

  @doc """
  This is a redirect for a name with additional placerholders.
  For example, for a request like "http://go/chill/1234/pretty",
  * "name" would be "chill"
  * "args" would be ["1234", "pretty"]
  """
  defp do_redirect(conn, name, args) do
    link = lookup_link(name)

    if link do
      query_url = link.query_url
      filled_url = fill_query_url(query_url, args)

      redirect conn, external: filled_url
    else
      conn
      |> put_status(:not_found)
      |> render(GoLinks.ErrorView, "404.html")
    end
  end

  defp lookup_link(name) do
    Repo.get_by(Link, name: name)
  end

  @doc """
  Given a query_url like "https://jira.fitbit.com/browse/IPD-%s/what/%s",
  fill the placeholders (%s) with the args.
  """
  defp fill_query_url(query_url, [head | rest]) do
    if String.contains?(query_url, @placeholder) do
      replaced = String.replace(query_url, @placeholder, head, global: false)
      fill_query_url(replaced, rest)
    else
      query_url
    end
  end
end
