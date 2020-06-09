defmodule GRPCClientPool.Client do
  require Logger
  use GenServer

  def start_link([config]) do
    GenServer.start_link(__MODULE__, [config])
  end

  def init([config]) do
    Process.flag(:trap_exit, true)

    {:ok, nil, {:continue, config}}
  end

  def handle_continue(config, _) do
    case GRPC.Stub.connect(config[:url], config[:connect_opts]) do
      {:ok, channel} ->
        {:noreply, channel}

      {:error, error} ->
        Logger.error("Unable to connect to GRPC endpoint: #{inspect(error)}")
        Process.send_after(self(), {:reconnect, config}, config[:reconnect_interval])
        {:noreply, nil}
    end
  end

  def handle_info({:reconnect, config}, _) do
    case GRPC.Stub.connect(config[:url], config[:connect_opts]) do
      {:ok, channel} ->
        {:noreply, channel}

      {:error, error} ->
        IO.inspect(self())
        Logger.error("Unable to connect to GRPC endpoint: #{inspect(error)}")
        Process.send_after(self(), {:reconnect, config}, config[:reconnect_interval])
        {:noreply, nil}
    end
  end

  def terminate(reason, nil), do: :noop

  def terminate(reason, channel) do
    GRPC.Stub.disconnect(channel)
  end

  def handle_call(:get_channel, _, channel), do: {:reply, channel, channel}
end
