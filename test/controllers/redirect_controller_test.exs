defmodule GoLinks.RedirectControllerTest do
  use GoLinks.ConnCase
  require IEx

  # alias GoLinks.Link
  @valid_attrs %{name: "some content", url: "https://www.google.com"}
  @invalid_attrs %{name: ""}

  test "should receive 404 'Page not found' for non-existent link", %{conn: conn} do
    IEx.pry
    conn = get conn, redirect_path(conn, :handle_redirect, "badlink")
    # conn = get conn, "/badlink"
    assert html_response(conn, 404) =~ "Page not found"
  end
end
