# GRPCClientPool Elixir

[![Hex.pm](https://img.shields.io/hexpm/v/grpc_client_pool.svg)](https://hex.pm/packages/grpc_client_pool)

A connection pooling library to be used along with [grpc](https://github.com/elixir-grpc/grpc) to create a connection pool of gRPC clients

## Installation

The package can be installed with:

```elixir
def deps do
  [
    {:grpc_client_pool, "~> 0.0.1-beta"}
  ]
end
```

## Usage

1. Follow [grpc](https://github.com/elixir-grpc/grpc) instructions on how to generate the elixir code
2. Create a module in your app that will act as a client and make it use the connection pool:

```elixir
defmodule MyApp.GRPCClient do
  use GRPCClientPool,
    otp_app: :my_app
end
```

3. Configure the client:
```elixir
config :my_app, MyApp.GRPCClient,
  size: 2,                                  
  max_overflow: 10,
  url: "localhost:50051,
  connect_opts: []
```

4. Add client requests within your new module:

```elixir
defmodule MyApp.GRPCClient do
  use GRPCClientPool,
    otp_app: :my_app

  alias GeneratedProto.ApiInput
  alias GeneratedProto.ApiService.Stub

  def remote_function(%ApiInput{} = params) do
    with_channel(fn channel ->
      Stub.remote_function(channel, params)
    end)
  end
end
```

## Options

The available configuration parameters are:

| Name         | Default | Required | Description                                                                                                                                                                     |
|--------------|---------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| size         | 2       | false    | Poolboy size parameter                                                                                                                                                          |
| max_overflow | 10      | false    | Poolboy max_overflow parameter                                                                                                                                                  |
| url          | nil     | true     | The url to be used as first argument of `GRPC.Stub.connect/2`. Can be either a string or {:system, "ENV"} or {:system, "ENV", "default"} to load the value from an env variable |
| connect_opts | []      | false    | The second argument passed to `GRPC.Stub.connect/2`                                                                                                                             |

## TODO

- [] Better naming logic for poolboy's pool
- [] Tests
- [] Configurable checkout timeout
- [] Better way of getting channel
- [] Handle connection errors
- [] Module docs
