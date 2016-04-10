defmodule GoLinks.RedirectController do
  use GoLinks.Web, :controller

  alias GoLinks.Link

  def handle_redirect(conn, %{"path" => path} = params) do
    IO.puts "params: #{inspect params}"
    [name | placeholders] = path

    link = lookup_link(name)

    if link do
      redirect conn, external: link.url
    else
      conn
      |> put_status(:not_found)
      |> render(GoLinks.ErrorView, "404.html")
    end
  end

  defp lookup_link(name) do
    Repo.get_by(Link, name: name)
  end
end
