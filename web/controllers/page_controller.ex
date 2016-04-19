defmodule GoLinks.PageController do
  require Logger
  use GoLinks.Web, :controller

  def faq(conn, _params) do
    render(conn, "faq.html")
  end

end
