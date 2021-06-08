defmodule RevisionWeb.PageControllerTest do
  use RevisionWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Tablas de multiplicar"
  end
end
