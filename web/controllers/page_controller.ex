defmodule GoLinks.PageController do
  use GoLinks.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
