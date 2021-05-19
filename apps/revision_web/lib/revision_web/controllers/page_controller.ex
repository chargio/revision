defmodule RevisionWeb.PageController do
  use RevisionWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
