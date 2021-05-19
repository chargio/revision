defmodule Revision.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Revision.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Revision.PubSub}
      # Start a worker by calling: Revision.Worker.start_link(arg)
      # {Revision.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Revision.Supervisor)
  end
end
