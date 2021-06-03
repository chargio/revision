defmodule QuizServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: QuizServer.Worker.start_link(arg)
      # {QuizServer.Worker, arg}
      {QuizServer.Boundary.TemplateManager, [name: QuizServer.Boundary.TemplateManager]},
      {Registry, [name: QuizServer.Registry.QuizSession, keys: :unique]},
      {DynamicSupervisor, [name: QuizServer.Supervisor.QuizSession, strategy: :one_for_one]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuizServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
