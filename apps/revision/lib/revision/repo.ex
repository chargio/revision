defmodule Revision.Repo do
  use Ecto.Repo,
    otp_app: :revision,
    adapter: Ecto.Adapters.Postgres
end
