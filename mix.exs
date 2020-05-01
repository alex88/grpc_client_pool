defmodule GRPCClientPool.MixProject do
  use Mix.Project

  @version "0.0.1-beta"

  def project do
    [
      app: :grpc_client_pool,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir GRPC client pooling library",
      package: package(),
      docs: [
        extras: ["README.md"],
        main: "readme",
        source_ref: "v#{@version}",
        source_url: "https://github.com/alex88/grpc_client_pool"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poolboy, "~> 1.5"},
      {:grpc, "~> 0.5.0-beta"},
      {:ex_doc, "~> 0.21", only: :dev}
    ]
  end

  defp package do
    [
      maintainers: ["Alessandro Tagliapietra"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alex88/grpc_client_pool"},
      files: ~w(.formatter.exs mix.exs README.md lib)
    ]
  end
end
