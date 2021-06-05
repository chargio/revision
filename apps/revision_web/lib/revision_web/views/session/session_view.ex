defmodule RevisionWeb.SessionView do
  use RevisionWeb, :view


  def random_session_id(length \\ 5) do
    for _i <- 1..length, do: [?A..?Z|> Enum.random] |> to_string, into: ""
  end
end
