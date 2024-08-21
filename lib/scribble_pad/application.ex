defmodule ScribblePad.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {NodeJS.Supervisor, [path: LiveSvelte.SSR.NodeJS.server_path(), pool_size: 4]},
      ScribblePadWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:scribble_pad, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ScribblePad.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ScribblePad.Finch},
      # Start a worker by calling: ScribblePad.Worker.start_link(arg)
      # {ScribblePad.Worker, arg},
      # Start to serve requests, typically the last entry
      ScribblePadWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ScribblePad.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ScribblePadWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
