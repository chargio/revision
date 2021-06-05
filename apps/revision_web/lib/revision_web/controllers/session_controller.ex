defmodule RevisionWeb.SessionController do
  use RevisionWeb, :controller


  # Make sure that the session is created before it is called

  def new_or_existing_session(name, uid) do
    {name, uid}
  end

  def new(conn, %{"number" => number}) do
    render(conn, "new.html", number: number)
  end

  def show(conn, %{"uid" => uid}) do
    render(conn, "show.html", uid: uid)
  end

  def update(conn, %{"uid" => uid, "response" => response}) do
    render(conn, "update.html", uid: uid, response: response)
  end
 end
