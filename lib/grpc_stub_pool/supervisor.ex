defmodule GRPCClientPool.Supervisor do
  @moduledoc false
  use Supervisor

  @defaults [size: 2, max_overflow: 10, connect_opts: [], reconnect_interval: 5_000]

  @doc """
  Retrieves the compile time configuration.
  """
  def compile_config(_module, opts) do
    otp_app = opts[:otp_app]

    unless otp_app do
      raise ArgumentError, "missing :otp_app option on use GRPCClientPool"
    end

    {otp_app}
  end

  @doc """
  Retrieves the runtime configuration.
  """
  def runtime_config(client_pool, otp_app) do
    config = Application.get_env(otp_app, client_pool, [])
    config = [otp_app: otp_app] ++ (@defaults |> Keyword.merge(config))
    validate_config!(client_pool, config)
    config = Keyword.put(config, :url, parse_url(config[:url]))
    config
  end

  @doc """
  Starts the client pool supervisor.
  """
  def start_link(client_pool, otp_app) do
    Supervisor.start_link(__MODULE__, {client_pool, otp_app}, name: client_pool)
  end

  @doc """
  Returns the poolboy name based on the main pool name
  """
  def poolboy_name(client_pool) do
    "#{client_pool}.Pool" |> String.to_atom()
  end

  defp validate_config!(client_pool, config) do
    unless Keyword.has_key?(config, :url) do
      raise ArgumentError, "missing :url option on #{client_pool} config"
    end
  end

  defp parse_url({:system, env, default}), do: System.get_env(env, default)
  defp parse_url({:system, env}), do: System.get_env(env)
  defp parse_url(url), do: url

  ## Callbacks

  @doc false
  def init({client_pool, otp_app}) do
    config = runtime_config(client_pool, otp_app)

    poolboy_config = [
      name: {:local, poolboy_name(client_pool)},
      worker_module: GRPCClientPool.Client,
      size: config[:size],
      max_overflow: config[:max_overflow]
    ]

    children = [
      :poolboy.child_spec(client_pool, poolboy_config, [config])
    ]

    Supervisor.init(children, strategy: :one_for_one, max_restarts: 10, max_seconds: 1)
  end
end
