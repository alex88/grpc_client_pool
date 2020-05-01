defmodule GRPCClientPool.Client do
  use GenServer

  def start_link([config]) do
    GenServer.start_link(__MODULE__, [config])
  end

  def init([config]) do
    Process.flag(:trap_exit, true)

    case GRPC.Stub.connect(config[:url], config[:connect_opts]) do
      {:ok, channel} -> {:ok, channel}
      {:error, error} -> {:stop, error}
    end
  end

  def terminate(_reason, channel) do
    GRPC.Stub.disconnect(channel)
  end

  def handle_call(:get_channel, _, channel), do: {:reply, channel, channel}
end
